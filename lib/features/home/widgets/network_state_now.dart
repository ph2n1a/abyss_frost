import 'package:flutter/material.dart';
import 'package:abyss_frost/core/court/court.dart';
import 'package:abyss_frost/core/court/judge.dart';

class NetworkStateNow extends StatelessWidget {
  final Court court;

  const NetworkStateNow({
    super.key,
    required this.court,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: court.textVerdict,
      builder: (context, verdict, child) {
        final currentVerdict = court.verdict;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade800),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                _getIcon(currentVerdict),
                color: _getColor(currentVerdict),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  verdict,
                  style: TextStyle(
                    color: _getColor(currentVerdict),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIcon(Verdict v) {
    switch (v) {
      case Verdict.noInternet:
        return Icons.wifi_off_rounded;
      case Verdict.whitelist:
        return Icons.lock_outline;
      case Verdict.defaultInternet:
        return Icons.public;
      case Verdict.fullAccess:
        return Icons.wifi_rounded;
      case Verdict.unstableConnection:
        return Icons.signal_wifi_statusbar_connected_no_internet_4;
      case Verdict.outsideRussia:
        return Icons.flight_takeoff;
      case Verdict.error:
        return Icons.error_outline;
      case Verdict.waiting:
        return Icons.hourglass_empty;
    }
  }

  Color _getColor(Verdict v) {
    switch (v) {
      case Verdict.noInternet:
        return Colors.red;
      case Verdict.whitelist:
        return Colors.white;
      case Verdict.defaultInternet:
        return Colors.green;
      case Verdict.fullAccess:
        return Colors.lightGreenAccent;
      case Verdict.unstableConnection:
        return Colors.yellow;
      case Verdict.outsideRussia:
        return Colors.lightGreen;
      case Verdict.error:
        return Colors.red;
      case Verdict.waiting:
        return Colors.grey;
    }
  }
}