class CircuitBreakerConfig {
  const CircuitBreakerConfig({
    this.failureThreshold = 3,
    this.successThreshold = 1,
    this.openDurationMs = 30000,
    this.backoffFactor = 2.0,
    this.maxOpenDurationMs = 300000,
  })  : assert(failureThreshold > 0, 'failureThreshold must be positive'),
        assert(openDurationMs > 0, 'openDurationMs must be positive');

  final int failureThreshold;
  final int successThreshold;
  final int openDurationMs;
  final double backoffFactor;
  final int maxOpenDurationMs;

  const CircuitBreakerConfig.telemetry()
      : failureThreshold = 5,
        successThreshold = 2,
        openDurationMs = 30000,
        backoffFactor = 2.0,
        maxOpenDurationMs = 300000;

  const CircuitBreakerConfig.aggressive()
      : failureThreshold = 1,
        successThreshold = 1,
        openDurationMs = 5000,
        backoffFactor = 2.0,
        maxOpenDurationMs = 60000;
}
