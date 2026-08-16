package com.devnetspace.abyss_frost.network_prober

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import java.net.HttpURLConnection
import java.net.InetSocketAddress
import java.net.Proxy
import java.net.URL
import java.security.SecureRandom
import java.security.cert.X509Certificate
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicReference
import javax.net.ssl.HostnameVerifier
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.SSLSession
import javax.net.ssl.SSLSocketFactory
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager

class NetworkProberPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var context: Context
    private val mainHandler = Handler(Looper.getMainLooper())
    companion object {
        private const val TAG = "NetworkProber"
    }

    private var physicalNetwork: Network? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine: Plugin initializing")
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.abyss_frost/network_prober")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "com.abyss_frost/network_prober_events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                Log.d(TAG, "EventChannel: Dart subscribed to stream")
                eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                Log.d(TAG, "EventChannel: Dart unsubscribed")
                eventSink = null
            }
        })
        Log.d(TAG, "Plugin attached and channels initialized successfully")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine: Cleaning up resources")
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        physicalNetwork = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            "isVpnActive" -> result.success(isVpnActive())
            "isWifiConnected" -> result.success(isWifiConnected())
            "bindToPhysicalNetwork" -> bindToPhysicalNetwork(result)
            "unbindNetwork" -> {
                Log.d(TAG, "unbindNetwork: Clearing physical network reference")
                physicalNetwork = null
                result.success(true)
            }
            "probeUrls" -> probeUrls(call, result)
            else -> {
                Log.w(TAG, "onMethodCall: Method not implemented - ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun isVpnActive(): Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val activeNetwork = cm.activeNetwork ?: return false
            val caps = cm.getNetworkCapabilities(activeNetwork) ?: return false
            caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN).also {
                Log.d(TAG, "isVpnActive: $it")
            }
        } else {
            Log.w(TAG, "isVpnActive: Android < M, returning false")
            false
        }
    }

    private fun isWifiConnected(): Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val activeNetwork = cm.activeNetwork ?: return false
            val caps = cm.getNetworkCapabilities(activeNetwork) ?: return false
            caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI).also {
                Log.d(TAG, "isWifiConnected (M+): $it")
            }
        } else {
            @Suppress("DEPRECATION")
            val isWifi = cm.activeNetworkInfo?.type == ConnectivityManager.TYPE_WIFI
            Log.d(TAG, "isWifiConnected (Legacy): $isWifi")
            isWifi
        }
    }

    private fun bindToPhysicalNetwork(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            Log.w(TAG, "bindToPhysicalNetwork: Android < M, not supported")
            result.success(false)
            return
        }

        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        val existingNetwork = findExistingPhysicalNetwork(cm)
        if (existingNetwork != null) {
            physicalNetwork = existingNetwork
            Log.d(TAG, "bindToPhysicalNetwork: Successfully bound to EXISTING network: $physicalNetwork")
            result.success(true)
            return
        }

        Log.d(TAG, "bindToPhysicalNetwork: No existing network found, requesting new one")
        val builder = NetworkRequest.Builder().addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            builder.addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
        }

        val latch = CountDownLatch(1)
        val foundNetwork = AtomicReference<Network?>(null)

        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                val caps = cm.getNetworkCapabilities(network)
                if (caps != null && isUsablePhysicalNetwork(caps) && isNetworkActuallyUsable(network)) {
                    Log.d(TAG, "NetworkCallback: Found usable new network: $network")
                    foundNetwork.set(network)
                    latch.countDown()
                } else {
                    Log.w(TAG, "NetworkCallback: Network $network rejected (locked down or unusable)")
                }
            }
        }

        try {
            cm.requestNetwork(builder.build(), callback)
            Thread {
                var success = false
                try {
                    if (latch.await(2500, TimeUnit.MILLISECONDS) && foundNetwork.get() != null) {
                        physicalNetwork = foundNetwork.get()
                        success = true
                        Log.d(TAG, "bindToPhysicalNetwork: Successfully bound to NEW network: $physicalNetwork")
                    } else {
                        Log.w(TAG, "bindToPhysicalNetwork: Timeout (2500ms) or no network found")
                    }
                } finally {
                    try { cm.unregisterNetworkCallback(callback) } catch (_: Exception) {}
                }
                mainHandler.post { result.success(success) }
            }.start()
        } catch (e: Exception) {
            Log.e(TAG, "bindToPhysicalNetwork: Exception during request: ${e.message}")
            result.success(false)
        }
    }

    private fun findExistingPhysicalNetwork(cm: ConnectivityManager): Network? {
        return try {
            Log.d(TAG, "findExistingPhysicalNetwork: Scanning ${cm.allNetworks.size} total networks")
            cm.allNetworks.firstOrNull { network ->
                val caps = cm.getNetworkCapabilities(network) ?: return@firstOrNull false

                if (!isUsablePhysicalNetwork(caps)) return@firstOrNull false

                val actuallyUsable = isNetworkActuallyUsable(network)
                if (actuallyUsable) {
                    Log.d(TAG, "findExistingPhysicalNetwork: MATCH FOUND: $network")
                } else {
                    Log.w(TAG, "findExistingPhysicalNetwork: Network $network has correct flags but is LOCKED DOWN (EPERM)")
                }
                actuallyUsable
            }
        } catch (e: Exception) {
            Log.e(TAG, "findExistingPhysicalNetwork: Error scanning networks: ${e.message}")
            null
        }
    }

    private fun isNetworkActuallyUsable(network: Network): Boolean {
        val latch = CountDownLatch(1)
        val result = AtomicBoolean(false)

        Thread {
            try {
                val url = URL("https://www.google.com/generate_204")
                val connection = network.openConnection(url) as HttpURLConnection
                connection.connectTimeout = 1500
                connection.readTimeout = 1500
                connection.requestMethod = "HEAD"
                connection.instanceFollowRedirects = false

                Log.d(TAG, "isNetworkActuallyUsable: Testing micro-connection on $network...")
                connection.connect()
                connection.disconnect()

                Log.d(TAG, "isNetworkActuallyUsable: Network $network is ACTUALLY USABLE (no EPERM)")
                result.set(true)
            } catch (e: Exception) {
                val fullMsg = "${e.message} ${e.cause?.message} ${e.javaClass.simpleName}"

                if (fullMsg.contains("EPERM") || fullMsg.contains("Binding socket") || fullMsg.contains("Operation not permitted")) {
                    Log.w(TAG, "isNetworkActuallyUsable: Network $network is LOCKED DOWN (EPERM): $fullMsg")
                    result.set(false)
                } else if (e is java.net.SocketTimeoutException || fullMsg.contains("timeout", ignoreCase = true)) {
                    Log.w(TAG, "isNetworkActuallyUsable: Network $network timed out, assuming usable (no lockdown)")
                    result.set(true)
                } else {
                    Log.w(TAG, "isNetworkActuallyUsable: Network $network failed check: $fullMsg")
                    result.set(false)
                }
            } finally {
                latch.countDown()
            }
        }.start()

        return try {
            if (latch.await(2000, TimeUnit.MILLISECONDS)) result.get() else {
                Log.w(TAG, "isNetworkActuallyUsable: Check timed out for $network")
                false
            }
        } catch (e: InterruptedException) {
            false
        }
    }

    private fun isUsablePhysicalNetwork(caps: NetworkCapabilities): Boolean {
        if (caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) {
            Log.d(TAG, "isUsablePhysicalNetwork: Rejected (has VPN transport)")
            return false
        }
        if (!caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)) {
            Log.d(TAG, "isUsablePhysicalNetwork: Rejected (no INTERNET capability)")
            return false
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val notVpn = caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
            if (!notVpn) Log.d(TAG, "isUsablePhysicalNetwork: Rejected (no NOT_VPN capability)")
            return notVpn
        }
        Log.d(TAG, "isUsablePhysicalNetwork: Approved by flags")
        return true
    }

    private fun probeUrls(call: MethodCall, result: MethodChannel.Result) {
        val urls = call.argument<List<String>>("urls") ?: emptyList()
        val method = call.argument<String>("method") ?: "HEAD"
        val timeoutMs = call.argument<Int>("timeoutMs") ?: 10000
        val proxyHost = call.argument<String>("proxyHost")
        val proxyPort = call.argument<Int>("proxyPort")
        val acceptInvalidCerts = call.argument<Boolean>("acceptInvalidCerts") ?: false
        val maxRedirects = call.argument<Int>("maxRedirects") ?: 5

        Log.d(TAG, "probeUrls: urls=${urls.size}, method=$method, timeout=${timeoutMs}ms, proxy=$proxyHost:$proxyPort")

        val proxy: Proxy? = if (!proxyHost.isNullOrEmpty() && proxyPort != null && proxyPort > 0) {
            Proxy(Proxy.Type.HTTP, InetSocketAddress(proxyHost, proxyPort))
        } else null

        if (acceptInvalidCerts) installTrustAllSsl()

        Thread {
            val finalResults = mutableListOf<Map<String, Any?>>()
            for (i in urls.indices) {
                Log.d(TAG, "probeUrls: Probing [$i/${urls.size}] ${urls[i]}")
                val singleResult = probeSingleUrl(urls[i], method, timeoutMs, proxy, acceptInvalidCerts, maxRedirects)
                finalResults.add(singleResult)

                mainHandler.post {
                    eventSink?.success(singleResult)
                    Log.d(TAG, "probeUrls: 📤 Sent real-time result for ${urls[i]}")
                }
            }
            Log.d(TAG, "probeUrls: All URLs probed, returning final list")
            mainHandler.post { result.success(finalResults) }
        }.start()
    }

    private fun probeSingleUrl(
        rawUrl: String, method: String, timeoutMs: Int, proxy: Proxy?,
        acceptInvalidCerts: Boolean, maxRedirects: Int
    ): Map<String, Any?> {
        val fullUrl = if (rawUrl.startsWith("http://") || rawUrl.startsWith("https://")) rawUrl else "https://$rawUrl"
        val startTime = System.currentTimeMillis()
        val maxTotalTimeMs = timeoutMs.toLong()

        var currentUrl = fullUrl
        var statusCode: Int? = null
        var errorMessage: String? = null
        var redirects = 0
        var usePhysicalNetwork = true

        var activeConnection: HttpURLConnection? = null
        val connectionLock = Any()
        var isFinished = false

        val watchdog = Thread {
            try {
                val sleepTime = maxTotalTimeMs - (System.currentTimeMillis() - startTime)
                if (sleepTime > 0) Thread.sleep(sleepTime)
                synchronized(connectionLock) {
                    if (!isFinished) {
                        Log.w(TAG, "probeSingleUrl: Watchdog triggered! Forcing disconnect for $fullUrl")
                        activeConnection?.disconnect()
                    }
                }
            } catch (_: InterruptedException) {}
        }
        watchdog.start()

        try {
            var iteration = 0
            while (true) {
                iteration++
                val elapsed = System.currentTimeMillis() - startTime
                if (elapsed >= maxTotalTimeMs) {
                    Log.w(TAG, "probeSingleUrl: Total timeout reached ($elapsed ms)")
                    errorMessage = "Timeout"
                    break
                }

                Log.d(TAG, "probeSingleUrl: Iteration $iteration, usePhysical=$usePhysicalNetwork, url=$currentUrl")

                val connection: HttpURLConnection = if (usePhysicalNetwork) {
                    openConnectionViaPhysicalNetwork(URL(currentUrl), proxy) as HttpURLConnection
                } else {
                    Log.d(TAG, "probeSingleUrl: Fallback to default network (VPN)")
                    (if (proxy != null) URL(currentUrl).openConnection(proxy) else URL(currentUrl).openConnection()) as HttpURLConnection
                }

                synchronized(connectionLock) { activeConnection = connection }

                try {
                    connection.requestMethod = method
                    val remainingTime = maxTotalTimeMs - elapsed
                    connection.connectTimeout = minOf(timeoutMs.toLong(), remainingTime).toInt()
                    connection.readTimeout = connection.connectTimeout
                    connection.instanceFollowRedirects = false
                    connection.setRequestProperty("Connection", "close")
                    connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
                    connection.setRequestProperty("Accept", "*/*")

                    if (connection is HttpsURLConnection && acceptInvalidCerts) {
                        val sc = SSLContext.getInstance("TLS")
                        sc.init(null, arrayOf<TrustManager>(TrustAllManager), SecureRandom())
                        connection.sslSocketFactory = sc.socketFactory as SSLSocketFactory
                        connection.hostnameVerifier = TrustAllHostnameVerifier
                    }

                    connection.connect()
                    statusCode = connection.responseCode
                    Log.d(TAG, "probeSingleUrl: Got status code $statusCode")

                    if (statusCode in 300..399 && redirects < maxRedirects) {
                        val location = connection.getHeaderField("Location")
                        if (location != null) {
                            currentUrl = URL(URL(currentUrl), location).toString()
                            redirects++
                            Log.d(TAG, "probeSingleUrl: Redirect #$redirects to $currentUrl")
                            connection.disconnect()
                            continue
                        }
                    }
                    connection.disconnect()
                    break

                } catch (e: java.net.SocketException) {
                    val msg = e.message ?: ""
                    Log.e(TAG, "probeSingleUrl: SocketException: $msg")

                    if (msg.contains("Socket closed") || msg.contains("Connection reset") || (System.currentTimeMillis() - startTime) >= maxTotalTimeMs) {
                        Log.w(TAG, "probeSingleUrl: Connection interrupted by watchdog/timeout")
                        errorMessage = "Timeout"
                        try { connection.disconnect() } catch (_: Exception) {}
                        break
                    }

                    if (usePhysicalNetwork && (msg.contains("EPERM") || msg.contains("Binding socket"))) {
                        Log.w(TAG, "probeSingleUrl: EPERM (Lockdown) detected mid-request! Falling back to default network.")
                        usePhysicalNetwork = false
                        try { connection.disconnect() } catch (_: Exception) {}
                        continue
                    } else {
                        throw e
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "probeSingleUrl: Exception: ${e.javaClass.simpleName}: ${e.message}")
                    errorMessage = if ((System.currentTimeMillis() - startTime) >= maxTotalTimeMs) "Timeout" else classifyError(e)
                    try { connection.disconnect() } catch (_: Exception) {}
                    break
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "probeSingleUrl: Fatal exception: ${e.javaClass.simpleName}: ${e.message}")
            errorMessage = if ((System.currentTimeMillis() - startTime) >= maxTotalTimeMs) "Timeout" else classifyError(e)
        } finally {
            synchronized(connectionLock) { isFinished = true; activeConnection = null }
            watchdog.interrupt()
        }

        val latency = minOf((System.currentTimeMillis() - startTime).toInt(), timeoutMs)
        return mapOf(
            "url" to rawUrl, "statusCode" to statusCode, "latencyMs" to latency,
            "error" to errorMessage, "redirects" to redirects, "usedBypass" to usePhysicalNetwork
        )
    }

    private fun openConnectionViaPhysicalNetwork(url: URL, proxy: Proxy?): java.net.URLConnection {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && physicalNetwork != null) {
            Log.d(TAG, "openConnection: Using bound physical network")
            return if (proxy != null) physicalNetwork!!.openConnection(url, proxy) else physicalNetwork!!.openConnection(url)
        }
        Log.d(TAG, "openConnection: Using default system network")
        return if (proxy != null) url.openConnection(proxy) else url.openConnection()
    }

    private fun classifyError(e: Exception): String {
        val msg = e.message ?: ""
        return when {
            e is java.net.SocketTimeoutException || msg.contains("timeout", ignoreCase = true) -> "Timeout"
            msg.contains("SSL", ignoreCase = true) || e.javaClass.simpleName.contains("SSL") -> "SSL Error"
            msg.contains("UnknownHost", ignoreCase = true) || e.javaClass.simpleName == "UnknownHostException" -> "Unknown host"
            msg.contains("ECONNREFUSED", ignoreCase = true) -> "Connection refused"
            else -> "${e.javaClass.simpleName}: $msg"
        }
    }

    private fun installTrustAllSsl() {
        Log.w(TAG, "installTrustAllSsl: Installing INSECURE trust-all SSL context")
        try {
            val sc = SSLContext.getInstance("TLS")
            sc.init(null, arrayOf<TrustManager>(TrustAllManager), SecureRandom())
            HttpsURLConnection.setDefaultSSLSocketFactory(sc.socketFactory)
            HttpsURLConnection.setDefaultHostnameVerifier(TrustAllHostnameVerifier)
        } catch (e: Exception) {
            Log.e(TAG, "installTrustAllSsl failed: ${e.message}")
        }
    }

    private object TrustAllManager : X509TrustManager {
        override fun checkClientTrusted(chain: Array<out X509Certificate>?, authType: String?) {}
        override fun checkServerTrusted(chain: Array<out X509Certificate>?, authType: String?) {}
        override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
    }

    private object TrustAllHostnameVerifier : HostnameVerifier {
        override fun verify(hostname: String?, session: SSLSession?): Boolean {
            Log.w(TAG, "TrustAllHostnameVerifier: Accepting unverified hostname: $hostname")
            return true
        }
    }
}