# 🚨 긴급 수정 모듈 (150토큰)

## ⚡ 즉시 해결 방법

### 컴파일 오류
```dart
// JSON 직렬화 오류 → 제거
// toJson(), fromJson() 메서드 삭제

// Import 누락 → 추가
import 'package:flutter/material.dart';
```

### MCP 연결 실패
```powershell
# 1. 서버 상태 확인
Get-Process | Where-Object {$_.ProcessName -like "*uvx*"}

# 2. 재시작
taskkill /f /im uvx.exe
```

### 토큰 부족
```powershell
# 스마트 컨텍스트 활성화
.\smart_context_manager.ps1 -Action analyze -WorkContext "현재작업"
```

### Flutter 빌드 실패
```bash
flutter clean
flutter pub get
flutter run
```

## 🔧 빠른 체크리스트
- [ ] Import 문 확인
- [ ] JSON 직렬화 코드 제거
- [ ] MCP 서버 재연결
- [ ] Flutter 캐시 정리