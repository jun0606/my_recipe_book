# 개발 환경 설정 가이드

## 1. 필수 소프트웨어 설치

### 1.1 Flutter SDK
- **버전**: 3.10.0 이상
- **설치 방법**:
  1. [Flutter 공식 사이트](https://flutter.dev/docs/get-started/install)에서 운영체제에 맞는 SDK 다운로드
  2. 압축 해제 및 환경 변수 설정
  3. `flutter doctor` 명령어로 설치 확인

### 1.2 Dart SDK
- **버전**: 3.0.0 이상 (Flutter SDK에 포함)
- **확인 방법**: `dart --version`

### 1.3 Android Studio
- **버전**: 2022.1 이상
- **설치 방법**:
  1. [Android Studio 다운로드 페이지](https://developer.android.com/studio)에서 다운로드
  2. 설치 마법사 따라 설치
  3. Flutter 및 Dart 플러그인 설치

### 1.4 Xcode (macOS 전용)
- **버전**: 14.0 이상
- **설치 방법**: Mac App Store에서 다운로드

### 1.5 VS Code (선택 사항)
- **버전**: 최신 버전
- **설치 방법**:
  1. [VS Code 다운로드 페이지](https://code.visualstudio.com/download)에서 다운로드
  2. Flutter 및 Dart 확장 설치

### 1.6 Git
- **버전**: 2.30.0 이상
- **설치 방법**:
  - Windows: [Git for Windows](https://gitforwindows.org/) 다운로드
  - macOS: `brew install git` 또는 [Git 공식 사이트](https://git-scm.com/download/mac)
  - Linux: `sudo apt-get install git` 또는 해당 패키지 매니저 사용

## 2. 프로젝트 설정

### 2.1 저장소 클론
```bash
git clone https://github.com/username/my_recipe_book.git
cd my_recipe_book
```

### 2.2 의존성 설치
```bash
flutter pub get
```

### 2.3 환경 변수 설정
- `.env` 파일 생성 (필요한 경우)
```
API_KEY=your_api_key_here
```

### 2.4 개발용 인증서 설정 (iOS 개발 시)
```bash
cd ios
pod install
```

## 3. 에뮬레이터 및 시뮬레이터 설정

### 3.1 Android 에뮬레이터
1. Android Studio 실행
2. AVD Manager 열기 (Tools > AVD Manager)
3. '+ Create Virtual Device' 클릭
4. 기기 선택 (예: Pixel 4)
5. 시스템 이미지 선택 (API 30 이상 권장)
6. AVD 이름 지정 및 생성

### 3.2 iOS 시뮬레이터 (macOS 전용)
1. 터미널에서 다음 명령어 실행:
```bash
open -a Simulator
```
2. 시뮬레이터 메뉴에서 File > Open Simulator > iOS 기기 선택

## 4. 앱 실행 및 디버깅

### 4.1 앱 실행
```bash
# 디버그 모드로 실행
flutter run

# 특정 기기에서 실행
flutter run -d device_id

# 릴리스 모드로 실행
flutter run --release
```

### 4.2 디버깅
- **VS Code**: Run > Start Debugging (F5)
- **Android Studio**: Run > Debug
- **Hot Reload**: `r` 키 (터미널에서)
- **Hot Restart**: `R` 키 (터미널에서)

### 4.3 로그 확인
```bash
# 로그 스트림 보기
flutter logs

# 특정 기기의 로그만 보기
flutter logs -d device_id
```

## 5. 빌드 및 배포

### 5.1 Android 빌드
```bash
# APK 빌드
flutter build apk

# App Bundle 빌드 (Google Play 배포용)
flutter build appbundle
```

### 5.2 iOS 빌드 (macOS 전용)
```bash
# iOS 앱 빌드
flutter build ios

# 아카이브 생성 (Xcode에서)
# 1. Product > Archive
# 2. Organizer에서 배포 옵션 선택
```

### 5.3 웹 빌드 (선택 사항)
```bash
# 웹 앱 빌드
flutter build web
```

## 6. 테스트 실행

### 6.1 단위 테스트 및 위젯 테스트
```bash
# 모든 테스트 실행
flutter test

# 특정 테스트 파일 실행
flutter test test/unit_test.dart

# 커버리지 보고서 생성
flutter test --coverage
```

### 6.2 통합 테스트
```bash
# 통합 테스트 실행
flutter test integration_test
```

## 7. 코드 품질 관리

### 7.1 정적 분석
```bash
# 코드 분석
flutter analyze

# 특정 파일 분석
flutter analyze lib/main.dart
```

### 7.2 코드 포맷팅
```bash
# 코드 포맷 검사
flutter format --dry-run .

# 코드 포맷 적용
flutter format .
```

### 7.3 린트 규칙 설정
- `analysis_options.yaml` 파일에서 린트 규칙 설정

## 8. 문제 해결

### 8.1 Flutter 클린업
```bash
# Flutter 캐시 정리
flutter clean

# pub 캐시 정리
flutter pub cache clean
```

### 8.2 의존성 문제
```bash
# 의존성 업데이트
flutter pub upgrade

# 의존성 다운그레이드
flutter pub downgrade
```

### 8.3 플랫폼별 문제

#### Android
- Gradle 빌드 실패: `android/gradlew clean` 실행
- 서명 문제: `key.properties` 파일 확인

#### iOS
- Pod 설치 실패: `cd ios && pod repo update && pod install` 실행
- 빌드 설정 문제: Xcode에서 프로젝트 설정 확인

## 9. 유용한 도구 및 확장

### 9.1 VS Code 확장
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets
- Flutter Intl
- Better Comments

### 9.2 Android Studio 플러그인
- Flutter
- Dart
- Flutter Intl
- Flutter Snippets
- Flutter Enhancement Suite

### 9.3 기타 도구
- [DevTools](https://flutter.dev/docs/development/tools/devtools/overview): 성능 프로파일링 및 디버깅
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli): Firebase 설정 자동화
- [Mason](https://github.com/felangel/mason): 코드 생성 및 템플릿

## 10. 팀 개발 가이드

### 10.1 브랜치 전략
- `main`: 안정적인 릴리스 버전
- `develop`: 개발 중인 버전
- `feature/*`: 새로운 기능 개발
- `bugfix/*`: 버그 수정
- `release/*`: 릴리스 준비

### 10.2 코드 리뷰 프로세스
1. 기능 브랜치에서 개발
2. Pull Request 생성
3. 코드 리뷰 요청
4. 리뷰 피드백 반영
5. 승인 후 병합

### 10.3 지속적 통합 (CI)
- GitHub Actions 또는 다른 CI 도구 사용
- 모든 PR에 대해 테스트 자동 실행
- 코드 품질 검사 자동화