// lib/data/module_keywords.dart
// 모듈 키워드 데이터

/// 모듈 키워드 및 정보 데이터
class ModuleKeywords {
  /// 모듈 데이터 맵
  static const Map<String, Map<String, dynamic>> data = {
    'bread': {
      'name': '빵',
      'keywords': ['bread', '빵', '빵빵', 'breadmaking', '제빵'],
      'description': '빵 만들기 모드',
      'icon': '🍞',
    },
    'cake': {
      'name': '케이크',
      'keywords': ['cake', '케이크', 'birthday', '생일', 'wedding', '결혼'],
      'description': '케이크 만들기 모드',
      'icon': '🎂',
    },
    'cookie': {
      'name': '쿠키',
      'keywords': ['cookie', '쿠키', 'biscuit', '비스킷', 'cookies'],
      'description': '쿠키 만들기 모드',
      'icon': '🍪',
    },
    'pastry': {
      'name': '페이스트리',
      'keywords': ['pastry', '페이스트리', 'croissant', '크루아상', 'danish'],
      'description': '페이스트리 만들기 모드',
      'icon': '🥐',
    },
    'pizza': {
      'name': '피자',
      'keywords': ['pizza', '피자', 'dough', '반죽'],
      'description': '피자 만들기 모드',
      'icon': '🍕',
    },
    'yeast': {
      'name': '효모',
      'keywords': ['yeast', '효모', 'fermentation', '발효', 'proofing'],
      'description': '효모 발효 모드',
      'icon': '🧈',
    },
    'gluten': {
      'name': '글루텐',
      'keywords': ['gluten', '글루텐', 'protein', '단백질', 'structure'],
      'description': '글루텐 발달 모드',
      'icon': '🌾',
    },
    'sourdough': {
      'name': '사워도우',
      'keywords': ['sourdough', '사워도우', 'starter', '종균', 'natural'],
      'description': '사워도우 빵 모드',
      'icon': '🫠',
    },
  };

  /// 모듈 정보 맵 (간단한 버전)
  static const Map<String, Map<String, String>> moduleInfo = {
    'bread': {
      'name': '빵 모듈',
      'description': '기본 빵 만들기',
      'category': 'basic',
    },
    'cake': {
      'name': '케이크 모듈',
      'description': '케이크 및 디저트',
      'category': 'dessert',
    },
    'cookie': {
      'name': '쿠키 모듈',
      'description': '쿠키 및 비스킷',
      'category': 'dessert',
    },
    'pastry': {
      'name': '페이스트리 모듈',
      'description': '페이스트리 및 크루아상',
      'category': 'pastry',
    },
    'pizza': {
      'name': '피자 모듈',
      'description': '피자 반죽 및 토핑',
      'category': 'savory',
    },
    'yeast': {
      'name': '효모 모듈',
      'description': '효모 발효 관리',
      'category': 'fermentation',
    },
    'gluten': {
      'name': '글루텐 모듈',
      'description': '글루텐 발달 분석',
      'category': 'analysis',
    },
    'sourdough': {
      'name': '사워도우 모듈',
      'description': '자연 발효 빵',
      'category': 'advanced',
    },
  };

  /// 키워드로 모듈 찾기
  static String? findModuleByKeyword(String keyword) {
    final lowerKeyword = keyword.toLowerCase();

    for (final entry in data.entries) {
      final keywords = entry.value['keywords'] as List<String>;
      if (keywords.any((k) => lowerKeyword.contains(k.toLowerCase()))) {
        return entry.key;
      }
    }

    return null;
  }

  /// 모듈별 추천 키워드 가져오기
  static List<String> getKeywordsForModule(String moduleKey) {
    return data[moduleKey]?['keywords'] as List<String> ?? [];
  }

  /// 모듈 이름 가져오기
  static String getModuleName(String moduleKey) {
    return moduleInfo[moduleKey]?['name'] ?? moduleKey;
  }

  /// 모듈 설명 가져오기
  static String getModuleDescription(String moduleKey) {
    return moduleInfo[moduleKey]?['description'] ?? '';
  }

  /// 카테고리별 모듈 목록 가져오기
  static List<String> getModulesByCategory(String category) {
    return moduleInfo.entries
        .where((entry) => entry.value['category'] == category)
        .map((entry) => entry.key)
        .toList();
  }

  /// 모든 카테고리 가져오기
  static List<String> getAllCategories() {
    final categories = moduleInfo.values
        .map((info) => info['category'] as String)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
