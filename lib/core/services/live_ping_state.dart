enum LivePingPhase { idle, pinging, countdown, serviceStopped }
enum LivePingStatus { pending, pinging, success, error }

class LivePingResult {
  final String url;
  final LivePingStatus status;
  final int? statusCode;
  final int? latencyMs;
  final String? error;
  final String? networkDetails;
  final String? tag;

  LivePingResult({
    required this.url,
    required this.status,
    this.statusCode,
    this.latencyMs,
    this.error,
    this.networkDetails,
    this.tag,
  });

  LivePingResult copyWith({
    LivePingStatus? status,
    int? statusCode,
    int? latencyMs,
    String? error,
    String? networkDetails,
    String? tag,
  }) {
    return LivePingResult(
      url: url,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      latencyMs: latencyMs ?? this.latencyMs,
      error: error ?? this.error,
      networkDetails: networkDetails ?? this.networkDetails,
      tag: tag ?? this.tag,
    );
  }

  factory LivePingResult.fromMap(Map<String, dynamic> map) {
    return LivePingResult(
      url: map['url'] as String,
      status: LivePingStatus.values.firstWhere(
            (e) => e.name == (map['status'] as String? ?? 'success'),
        orElse: () => LivePingStatus.success,
      ),
      statusCode: map['statusCode'] as int?,
      latencyMs: map['latencyMs'] as int?,
      error: map['error'] as String?,
      networkDetails: map['networkDetails'] as String?,
      tag: map['tag'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'url': url,
    'status': status.name,
    'statusCode': statusCode,
    'latencyMs': latencyMs,
    'error': error,
    'networkDetails': networkDetails,
    'tag': tag,
  };
}

class LivePingState {
  final LivePingPhase phase;
  final int secondsToNext;
  final List<LivePingResult> results;

  LivePingState({
    this.phase = LivePingPhase.idle,
    this.secondsToNext = 0,
    this.results = const [],
  });

  LivePingState copyWith({
    LivePingPhase? phase,
    int? secondsToNext,
    List<LivePingResult>? results,
  }) {
    return LivePingState(
      phase: phase ?? this.phase,
      secondsToNext: secondsToNext ?? this.secondsToNext,
      results: results ?? this.results,
    );
  }
}