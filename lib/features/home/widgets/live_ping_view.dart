import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';
import 'package:abyss_frost/core/services/live_ping_state.dart';

class LivePingView extends StatelessWidget {
  final ValueListenable<LivePingState> state;

  const LivePingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return ValueListenableBuilder<LivePingState>(
      valueListenable: state,
      builder: (context, s, _) {
        if (s.phase == LivePingPhase.serviceStopped) {
          return const _StoppedCard();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade800),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(state: s, appColors: appColors),
              const Divider(height: 1, color: Colors.white12),
              _ResultsList(results: s.results, appColors: appColors),
            ],
          ),
        );
      },
    );
  }
}

class _StoppedCard extends StatelessWidget {
  const _StoppedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: const Row(
        children: [
          Icon(Icons.power_settings_new, color: Colors.grey, size: 28),
          SizedBox(width: 12),
          Text('Service is stopped', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}


class _Header extends StatelessWidget {
  final LivePingState state;
  final AppColors appColors;

  const _Header({required this.state, required this.appColors});

  @override
  Widget build(BuildContext context) {
    final isPinging = state.phase == LivePingPhase.pinging;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isPinging
                ? const SizedBox(
              key: ValueKey('pinging'),
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            )
                : Icon(
              key: const ValueKey('countdown'),
              Icons.timer_outlined,
              color: appColors.backColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isPinging
                  ? const Text(
                key: ValueKey('pinging_text'),
                'Pinging...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              )
                  : Text(
                key: ValueKey('countdown_text'),
                'To next ping: ${state.secondsToNext}s',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          if (isPinging)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: appColors.backColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: appColors.backColor.withOpacity(0.5)),
              ),
              child: Text(
                'LIVE',
                style: TextStyle(
                  color: appColors.backColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<LivePingResult> results;
  final AppColors appColors;

  const _ResultsList({required this.results, required this.appColors});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SizedBox(
        height: 60,
        child: Center(child: Text('Waiting for first cycle...', style: TextStyle(color: Colors.white54))),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10, indent: 16, endIndent: 16),
        itemBuilder: (context, i) => _ResultRow(result: results[i], appColors: appColors),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final LivePingResult result;
  final AppColors appColors;

  const _ResultRow({required this.result, required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _StatusIcon(result: result, appColors: appColors),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.url,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                _StatusSubtitle(result: result, appColors: appColors),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RightInfo(result: result),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final LivePingResult result;
  final AppColors appColors;

  const _StatusIcon({required this.result, required this.appColors});

  @override
  Widget build(BuildContext context) {
    switch (result.status) {
      case LivePingStatus.pinging:
        return SizedBox(
          width: 22, height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: appColors.backColor,
          ),
        );
      case LivePingStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.white38, size: 22);
      case LivePingStatus.success:
        final code = result.statusCode ?? 0;
        Color c;
        IconData icon;
        if (code >= 200 && code < 300) { c = Colors.greenAccent; icon = Icons.check_circle; }
        else if (code >= 300 && code < 400) { c = Colors.amber; icon = Icons.swap_horiz; }
        else if (code >= 400 && code < 500) { c = Colors.orangeAccent; icon = Icons.warning_amber; }
        else if (code >= 500) { c = Colors.redAccent; icon = Icons.error; }
        else { c = Colors.grey; icon = Icons.help; }
        return Icon(icon, color: c, size: 24);
      case LivePingStatus.error:
        return const Icon(Icons.cancel, color: Colors.redAccent, size: 24);
    }
  }
}

class _StatusSubtitle extends StatelessWidget {
  final LivePingResult result;
  final AppColors appColors;

  const _StatusSubtitle({required this.result, required this.appColors});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color = Colors.white54;

    switch (result.status) {
      case LivePingStatus.pinging:
        text = 'Pinging...';
        color = appColors.backColor;
        break;
      case LivePingStatus.pending:
        text = 'Waiting...';
        break;
      case LivePingStatus.success:
        text = result.error ?? 'No ping errors';
        color = Colors.white60;
        break;
      case LivePingStatus.error:
        text = 'Error: ${result.error ?? 'Unknown'}';
        color = Colors.redAccent;
    }

    return Text(
      text,
      style: TextStyle(color: color, fontSize: 12),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _RightInfo extends StatelessWidget {
  final LivePingResult result;

  const _RightInfo({required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.status == LivePingStatus.pinging || result.status == LivePingStatus.pending) {
      return const SizedBox(width: 60);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          result.statusCode?.toString() ?? '—',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          result.latencyMs != null ? '${result.latencyMs}ms' : '—',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}