import 'package:abyss_frost/core/services/live_ping_state.dart';

enum Verdict {
  noInternet,
  whitelist,
  defaultInternet,
  fullAccess,
  unstableConnection,
  outsideRussia,
  error,
  waiting,
}

Verdict evaluateJudge(List<LivePingResult> results) {
  if (results.isEmpty) return Verdict.waiting;

  int neutralTotal = 0;
  int blacklistTotal = 0;
  int whitelistTotal = 0;

  int neutralBlocked = 0;
  int blacklistBlocked = 0;
  int whitelistBlocked = 0;

  for (final r in results) {
    final tag = r.tag ?? 'neutral';
    final isBlocked = r.statusCode == null;

    switch (tag) {
      case 'neutral':
        neutralTotal++;
        if (isBlocked) neutralBlocked++;
        break;
      case 'blacklist':
        blacklistTotal++;
        if (isBlocked) blacklistBlocked++;
        break;
      case 'whitelist':
        whitelistTotal++;
        if (isBlocked) whitelistBlocked++;
        break;
    }
  }

  double safePercent(int blocked, int total) {
    if (total == 0) return 0.0;
    return blocked / total;
  }

  final percentBlockedNeutral = safePercent(neutralBlocked, neutralTotal);
  final percentBlockedBlack = safePercent(blacklistBlocked, blacklistTotal);
  final percentBlockedWhite = safePercent(whitelistBlocked, whitelistTotal);

  final neutralBlockedFlag =
      neutralBlocked > 0 && percentBlockedNeutral > 0.5;

  final blacklistBlockedFlag =
      blacklistBlocked > 0 && percentBlockedBlack > 0.1;

  final whitelistBlockedFlag =
      whitelistBlocked > 0 && percentBlockedWhite > 0.9;

  if (!neutralBlockedFlag && !blacklistBlockedFlag && !whitelistBlockedFlag) {
    return Verdict.fullAccess;
  }

  if (neutralBlockedFlag && blacklistBlockedFlag && whitelistBlockedFlag) {
    final sum =
        percentBlockedNeutral + percentBlockedBlack + percentBlockedWhite;
    return sum > 1.5 ? Verdict.noInternet : Verdict.unstableConnection;
  }

  if (neutralBlockedFlag && blacklistBlockedFlag) return Verdict.whitelist;
  if (neutralBlockedFlag && whitelistBlockedFlag) return Verdict.defaultInternet;
  if (blacklistBlockedFlag && whitelistBlockedFlag) return Verdict.unstableConnection;

  if (neutralBlockedFlag) return Verdict.unstableConnection;
  if (blacklistBlockedFlag) return Verdict.defaultInternet;

  if (whitelistBlockedFlag) {
    return percentBlockedWhite > 0.7
        ? Verdict.outsideRussia
        : Verdict.defaultInternet;
  }

  return Verdict.error;
}