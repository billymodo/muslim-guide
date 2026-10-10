/// Outcome of reconciling prayer notifications with the operating system.
enum ScheduleResultStatus {
  /// Notifications were scheduled successfully.
  scheduled,

  /// No location was available, so no scheduling was attempted.
  noLocation,

  /// Scheduling was not completed.
  failed,
}

/// Reason scheduling could not be completed.
enum ScheduleFailureReason {
  /// Android notification permission is denied or unavailable.
  notificationsDenied,

  /// Exact-alarm permission is denied or unavailable.
  exactAlarmsDenied,

  /// No future prayer times were available in the requested horizon.
  noPrayerTimes,

  /// The operating-system notification scheduler failed.
  schedulingFailed,
}

/// Explicit result for scheduling, no-location, and failure outcomes.
class ScheduleResult {
  const new _({
    required this.status,
    this.scheduledCount = 0,
    this.reason,
    this.error,
  });

  /// Creates a successful result with the number of scheduled alarms.
  const new scheduled({required int scheduledCount})
    : this._(
        status: ScheduleResultStatus.scheduled,
        scheduledCount: scheduledCount,
      );

  /// Creates the explicit no-location result.
  const new noLocation() : this._(status: ScheduleResultStatus.noLocation);

  /// Creates a failure with a machine-readable reason and optional cause.
  const new failed({required ScheduleFailureReason reason, Object? error})
    : this._(status: ScheduleResultStatus.failed, reason: reason, error: error);

  /// Result category.
  final ScheduleResultStatus status;

  /// Number of notifications successfully scheduled.
  final int scheduledCount;

  /// Failure reason when [status] is [ScheduleResultStatus.failed].
  final ScheduleFailureReason? reason;

  /// Underlying cause when failure came from the platform scheduler.
  final Object? error;

  /// Whether schedule reconciliation succeeded.
  bool get isScheduled => status == ScheduleResultStatus.scheduled;

  /// Whether no location was available.
  bool get hasNoLocation => status == ScheduleResultStatus.noLocation;

  /// Whether scheduling failed.
  bool get hasFailed => status == ScheduleResultStatus.failed;
}
