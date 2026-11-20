/// What the scrobble queue is doing right now.
enum ScrobblePhase { idle, sending, retrying, authPaused }

/// Why the last delivery attempt failed (UI maps this to localized text).
enum ScrobbleIssue { network, auth, rejected }

/// Immutable snapshot of the scrobble pipeline, shown in settings.
class ScrobbleStatus {
  final int pending;
  final ScrobblePhase phase;
  final DateTime? lastSuccessAt;
  final String? lastTrack;
  final ScrobbleIssue? issue;
  final int rejectedCount;
  final DateTime? nextRetryAt;

  const ScrobbleStatus({
    this.pending = 0,
    this.phase = ScrobblePhase.idle,
    this.lastSuccessAt,
    this.lastTrack,
    this.issue,
    this.rejectedCount = 0,
    this.nextRetryAt,
  });

  ScrobbleStatus copyWith({
    int? pending,
    ScrobblePhase? phase,
    DateTime? lastSuccessAt,
    String? lastTrack,
    ScrobbleIssue? issue,
    bool clearIssue = false,
    int? rejectedCount,
    DateTime? nextRetryAt,
    bool clearRetry = false,
  }) =>
      ScrobbleStatus(
        pending: pending ?? this.pending,
        phase: phase ?? this.phase,
        lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
        lastTrack: lastTrack ?? this.lastTrack,
        issue: clearIssue ? null : (issue ?? this.issue),
        rejectedCount: rejectedCount ?? this.rejectedCount,
        nextRetryAt: clearRetry ? null : (nextRetryAt ?? this.nextRetryAt),
      );
}
