class MlStreamConfig {
  const MlStreamConfig({
    this.initialIntervalMs = 1000,
    this.maxIntervalMs = 30000,
    this.backoffFactor = 2.0,
    this.maxConsecutiveErrors = 5,
  }) : assert(
          initialIntervalMs < maxIntervalMs,
          'initialIntervalMs must be less than maxIntervalMs',
        );

  final int initialIntervalMs;
  final int maxIntervalMs;
  final double backoffFactor;
  final int maxConsecutiveErrors;

  const MlStreamConfig.production()
      : initialIntervalMs = 2000,
        maxIntervalMs = 30000,
        backoffFactor = 2.0,
        maxConsecutiveErrors = 5;
}
