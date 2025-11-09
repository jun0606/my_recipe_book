import 'package:my_recipe_book/models/analysis_result.dart';
import 'package:my_recipe_book/services/analysis/analysis_cache.dart';
import 'dart:collection'; // LinkedHashMap을 위해 필요

/// 메모리 기반 캐시 구현
///
/// LRU(Least Recently Used) 알고리즘을 사용하여 분석 결과를 메모리에 캐싱합니다.
class InMemoryCache implements AnalysisCache {
  final LinkedHashMap<String, _CacheEntry> _cache = LinkedHashMap();
  final int _maxSize; // 최대 캐시 엔트리 수
  int _hits = 0;
  int _misses = 0;

  InMemoryCache({int maxSize = 100}) : _maxSize = maxSize;

  @override
  Future<void> set(String key, AnalysisResult result, {int? ttl}) async {
    if (_cache.containsKey(key)) {
      _cache.remove(key); // 기존 엔트리 제거 (LRU 업데이트)
    } else if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first); // LRU 엔트리 제거
    }
    _cache[key] = _CacheEntry(result, DateTime.now().add(Duration(seconds: ttl ?? 1800))); // 기본 TTL 30분
  }

  @override
  Future<AnalysisResult?> get(String key) async {
    final entry = _cache[key];
    if (entry == null) {
      _misses++;
      return null;
    }

    if (entry.expiryTime.isBefore(DateTime.now())) {
      _cache.remove(key); // 만료된 엔트리 제거
      _misses++;
      return null;
    }

    // LRU 업데이트: 접근된 엔트리를 맨 뒤로 이동
    _cache.remove(key);
    _cache[key] = entry;
    _hits++;
    return entry.result;
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
    _hits = 0;
    _misses = 0;
  }

  @override
  Map<String, dynamic> getStats() {
    return {
      'total_entries': _cache.length,
      'max_size': _maxSize,
      'hits': _hits,
      'misses': _misses,
      'hit_rate': (_hits + _misses) == 0 ? 0.0 : _hits / (_hits + _misses),
    };
  }

  @override
  Future<void> initialize() async {
    // 초기화 로직 (필요시)
    print('InMemoryCache initialized.');
  }

  @override
  Future<void> dispose() async {
    // 정리 로직 (필요시)
    _cache.clear();
    print('InMemoryCache disposed.');
  }
}

/// 캐시 엔트리 내부 클래스
class _CacheEntry {
  final AnalysisResult result;
  final DateTime expiryTime;

  _CacheEntry(this.result, this.expiryTime);
}