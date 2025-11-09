# Provider 패턴 표준

## 단일 책임 원칙
- 하나의 Provider는 하나의 도메인만 담당
- DB 접근, 파일 처리, 상태 관리 분리

## 현재 문제점
- RecipeProvider가 너무 많은 책임을 가짐
- DB, SharedPreferences, 파일 처리 모두 포함

## 리팩토링 방향
1. RecipeRepository (DB 접근)
2. RecipeFileService (파일 처리) 
3. RecipeProvider (상태 관리만)

## 에러 처리
- try-catch 블록 필수
- 사용자 친화적 에러 메시지