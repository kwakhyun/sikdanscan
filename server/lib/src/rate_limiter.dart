typedef Clock = DateTime Function();

class RateLimiter {
  RateLimiter(this.limitPerMinute, {Clock? clock})
    : _clock = clock ?? DateTime.now;

  final int limitPerMinute;
  final Clock _clock;
  final Map<String, _RateBucket> _buckets = {};

  bool allow(String key) {
    if (limitPerMinute <= 0) return true;

    final now = _clock();
    _buckets.removeWhere(
      (_, bucket) => now.difference(bucket.startedAt).inMinutes >= 2,
    );

    final bucket = _buckets.putIfAbsent(key, () => _RateBucket(now));
    if (now.difference(bucket.startedAt).inMinutes >= 1) {
      bucket
        ..startedAt = now
        ..count = 0;
    }

    bucket.count += 1;
    return bucket.count <= limitPerMinute;
  }
}

class _RateBucket {
  _RateBucket(this.startedAt);

  DateTime startedAt;
  int count = 0;
}
