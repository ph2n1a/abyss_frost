import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:abyss_frost/core/services/live_ping_state.dart';
import 'judge.dart';

class Court {
  final ValueNotifier<String> _textVerdict = ValueNotifier<String>(
    'Waiting for the first cycle...',
  );
  Verdict _verdict = Verdict.waiting;

  ValueListenable<String> get textVerdict => _textVerdict;
  Verdict get verdict => _verdict;

  final ValueListenable<LivePingState> _pingState;
  LivePingPhase _lastPhase = LivePingPhase.serviceStopped;
  bool _evaluatedForCurrentCycle = false;

  Court(this._pingState) {
    _lastPhase = _pingState.value.phase;
    _evaluatedForCurrentCycle =
        (_lastPhase == LivePingPhase.countdown ||
        _lastPhase == LivePingPhase.idle);
    _pingState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = _pingState.value;

    if (state.phase == LivePingPhase.pinging &&
        _lastPhase != LivePingPhase.pinging) {
      _evaluatedForCurrentCycle = false;
    }

    if ((state.phase == LivePingPhase.countdown ||
            state.phase == LivePingPhase.idle) &&
        !_evaluatedForCurrentCycle) {
      final allCompleted =
          state.results.isNotEmpty &&
          state.results.every(
            (r) =>
                r.status != LivePingStatus.pinging &&
                r.status != LivePingStatus.pending,
          );

      if (allCompleted) {
        _calculateVerdict(state.results);
        _evaluatedForCurrentCycle = true;
      }
    }

    _lastPhase = state.phase;
  }

  void _calculateVerdict(List<LivePingResult> results) {
    try {
      final newVerdict = evaluateJudge(results);
      _verdict = newVerdict;

      _textVerdict.value = _verdictToText(newVerdict);
    } catch (e) {
      _verdict = Verdict.error;
      _textVerdict.value = 'Network analysis error';
      debugPrint('[Court] Error during evaluation: $e');
    }
  }

  String _verdictToText(Verdict v) {
    switch (v) {
      case Verdict.noInternet:
        return 'No Internet connection';
      case Verdict.whitelist:
        return 'Whitelist mode is enabled';
      case Verdict.unstableConnection:
        return 'Unstable internet connection';
      case Verdict.defaultInternet:
        return 'Default internet connection in Russia';
      case Verdict.fullAccess:
        return 'Full access to the Internet';
      case Verdict.outsideRussia:
        return 'You are abroad :D';
      case Verdict.error:
        return 'Network analysis error';
      case Verdict.waiting:
        return 'Waiting for the first cycle...';
    }
  }

  void dispose() {
    _pingState.removeListener(_onStateChanged);
    _textVerdict.dispose();
  }
}
