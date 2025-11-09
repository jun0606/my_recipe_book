# 수쉐프 모드 파일 구조 및 위치 목록
*생성일: 2025년 8월 31일*

## 📋 개요

이 문서는 My Recipe Book 프로젝트의 수쉐프 모드 관련 파일들의 현재 구조와 위치를 정리한 문서입니다. 최근 진행된 구조 재설계 작업 이후의 파일 배치를 확인할 수 있습니다.

## 🏗️ 전체 구조 개요

```
lib/
├── features/
│   └── chef/                    # 수쉐프 모드 메인 폴더
│       ├── core/               # 코어 컴포넌트 (비어있음)
│       ├── module/             # 모듈 시스템
│       ├── provider/           # 상태 관리 프로바이더
│       ├── screen/             # 화면 컴포넌트
│       └── widget/             # 위젯 컴포넌트
└── screens/                    # 기존 화면 구조
    └── special/
        └── chef/
            └── screen/         # (비어있음 - 이동 완료됨)
```

## 📁 상세 파일 목록

### 🎯 1. 메인 화면 파일
| 파일명 | 경로 | 설명 |
|--------|------|------|
| `sous_chef_mode_screen.dart` | `lib/features/chef/screen/` | 수쉐프 모드 메인 화면 위젯 |

### 🎨 2. 위젯 컴포넌트
| 파일명 | 경로 | 설명 |
|--------|------|------|
| `mixing_analysis_card.dart` | `lib/features/chef/widget/analysis/bread_analysis_cards/` | 믹싱 단계별 RPM 분석 및 시각화 |
| `baking_calculator.dart` | `lib/features/chef/widget/recipe_detail/` | 베이킹 시간 및 온도 계산기 |
| `ingredient_card_simple.dart` | `lib/features/chef/widget/recipe_detail/` | 간소화된 재료 정보 카드 |
| `instruction_step_simple.dart` | `lib/features/chef/widget/recipe_detail/` | 조리 단계별 지침 위젯 |

### 🔧 3. 프로바이더 (상태 관리)
| 파일명 | 경로 | 설명 |
|--------|------|------|
| `recipe_calculation_provider.dart` | `lib/features/chef/provider/` | 레시피 계산 및 분석 상태 관리 |

### 📦 4. 모듈 시스템
| 파일명 | 경로 | 설명 |
|--------|------|------|
| `base_module.dart` | `lib/features/chef/module/` | 모듈 시스템 베이스 클래스 |
| `module_manager.dart` | `lib/features/chef/module/` | 모듈 관리자 |
| `sous_chef_bread_module.dart` | `lib/features/chef/module/bread/` | 빵 제빙 전문 모듈 |
| `bread_module.dart` | `lib/features/chef/module/bread/core/` | 빵 모듈 코어 구현 |

### 📊 5. 모델 (데이터 구조)
| 파일명 | 경로 | 설명 |
|--------|------|------|
| `bread_analysis_data.dart` | `lib/features/chef/module/bread/models/` | 빵 분석 데이터 모델 |
| `integrated_mixing_analysis_types.dart` | `lib/features/chef/module/bread/models/` | 통합 믹싱 분석 타입 정의 |

### ⚙️ 6. 서비스 (비즈니스 로직)
| 파일명 | 경로 | 설명 |
|--------|------|------|
| `bread_baking_analyzer.dart` | `lib/features/chef/module/bread/services/` | 빵 베이킹 분석 서비스 |
| `bread_comprehensive_analyzer.dart` | `lib/features/chef/module/bread/services/` | 종합 빵 분석 서비스 |
| `bread_environment_analyzer.dart` | `lib/features/chef/module/bread/services/` | 빵 환경 분석 서비스 |
| `bread_oven_analyzer.dart` | `lib/features/chef/module/bread/services/` | 오븐 분석 서비스 |
| `bread_shaping_analyzer.dart` | `lib/features/chef/module/bread/services/` | 빵 성형 분석 서비스 |
| `brioche_texture_predictor.dart` | `lib/features/chef/module/bread/services/` | 브리오슈 텍스처 예측기 |
| `dough_type_analyzer.dart` | `lib/features/chef/module/bread/services/` | 반죽 타입 분석기 |
| `emulsion_stability_analyzer.dart` | `lib/features/chef/module/bread/services/` | 유화 안정성 분석기 |
| `integrated_mixing_analyzer.dart` | `lib/features/chef/module/bread/services/` | 통합 믹싱 분석기 |
| `mixing_stage_evaluator.dart` | `lib/features/chef/module/bread/services/` | 믹싱 단계 평가기 |

### 🎭 7. 타입 정의
| 파일명 | 경로 | 설명 |
|--------|------|------|
| `analysis_types.dart` | `lib/features/chef/module/bread/types/` | 분석 관련 타입 정의 |
| `bread_environment_types.dart` | `lib/features/chef/module/bread/types/` | 빵 환경 타입 정의 |
| `bread_types.dart` | `lib/features/chef/module/bread/types/` | 빵 종류 타입 정의 |
| `equipment_types.dart` | `lib/features/chef/module/bread/types/` | 장비 타입 정의 |
| `ingredient_types.dart` | `lib/features/chef/module/bread/types/` | 재료 타입 정의 |
| `README.md` | `lib/features/chef/module/bread/types/` | 타입 시스템 설명 문서 |

## 🔄 8. 기존 위치 파일들 (참조용)
| 파일명 | 기존 경로 | 상태 |
|--------|----------|------|
| `recipe_detail_screen.dart` | `lib/screens/` | 유지됨 (수쉐프 화면 참조) |
| `user_setup_screen.dart` | `lib/screens/special/user/screen/` | 유지됨 |
| `welcome_ceremony_screen.dart` | `lib/screens/special/guide/screen/` | 유지됨 |

## 📈 구조 분석

### ✅ 장점
1. **모듈화**: 수쉐프 관련 기능들이 하나의 폴더에 집중되어 관리 용이
2. **계층 구조**: screen → widget → module → services로 명확한 계층 분리
3. **기능별 그룹화**: 분석, 모델, 서비스, 타입을 논리적으로 분류
4. **확장성**: 새로운 빵 타입이나 분석 기능 추가가 용이

### ⚠️ 주의사항
1. **Import 경로**: 다른 파일에서 수쉐프 관련 컴포넌트를 사용할 때 경로 주의 필요
2. **의존성**: 모듈 간 의존성 관리가 중요
3. **테스트**: 각 모듈별 단위 테스트 필요

## 🎯 다음 단계 권장사항

1. **문서화**: 각 파일의 역할과 인터페이스 명확히 문서화
2. **테스트**: 단위 테스트 및 통합 테스트 작성
3. **리팩토링**: 중복 코드 제거 및 최적화
4. **배포**: 프로덕션 환경에서 검증

## 📝 변경 이력

- **2025-08-31**: 초기 파일 구조 문서화
- **수정자**: AI Assistant
- **버전**: v1.0

---

*이 문서는 프로젝트 구조 변경 시 함께 업데이트되어야 합니다.*
