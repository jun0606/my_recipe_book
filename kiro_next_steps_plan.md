# 🎯 KIRO v4.0 지침에 따른 다음 단계 계획

## 📋 현재 상황 분석 (KIRO v4.0 지침 준수)

### ✅ 완료된 작업
1. **KIRO v4.0 지침 위반 사항 분석 및 수정**
2. **오류 학습 시스템 기본 구조 구축**
3. **크로스 플랫폼 지원 시스템 설계**
4. **효율성 대시보드 기본 구현**
5. **한글 인코딩 문제 해결 및 학습**

### ❌ 해결해야 할 문제들
1. **통합 테스트 5개 실패** (UI 요소 찾기 문제)
2. **레이아웃 오버플로우** (199픽셀 초과)
3. **MCP 경로 접근 제한** (test 디렉토리)

## 🎯 KIRO v4.0 지침에 따른 해결 계획

### 1️⃣ 우선순위 1: 스마트 오류 복구 시스템 완성
```powershell
# 지침 준수: Invoke-KiroCommand 사용
$TestResult = Invoke-KiroCommand -Command "flutter test" -Parameters @{
    path = "test/integration/baking_calculator_phase2_integration_test.dart"
} -ErrorContext "통합 테스트 실행"
```

### 2️⃣ 우선순위 2: MCP 우선 사용 원칙 적용
```powershell
# MCP 서버 우선 사용, 실패시 대안 전략
try {
    $FileContent = mcp_filesystem_read_file -path $FilePath
} catch {
    # 오류 학습 시스템에 기록
    Record-ErrorPattern -ErrorType "MCP_ACCESS_DENIED" -ErrorMessage $_.Exception.Message
    # 대안 전략 실행
    $FileContent = Get-Content $FilePath -Encoding UTF8
}
```

### 3️⃣ 우선순위 3: 효율성 대시보드 활용
```powershell
# 작업 시작 전 반드시 실행
Show-KiroEfficiencyDashboard
Execute-OneClickOptimization

# 작업 진행 상황 모니터링
Performance-Monitor -TaskType "TEST_STABILIZATION" -StartTime $StartTime
```

## 🔧 구체적 실행 계획

### A. 통합 테스트 수정 (지침 준수)
1. **실제 구현 확인**: MCP 우선 사용으로 위젯 구조 분석
2. **테스트 코드 수정**: 실제 구현에 맞게 수정
3. **오류 패턴 기록**: 각 수정 사항을 학습 시스템에 기록

### B. 레이아웃 문제 해결 (지침 준수)
1. **스마트 명령어 사용**: `Invoke-KiroCommand`로 파일 수정
2. **크로스 플랫폼 고려**: 다양한 화면 크기 대응
3. **성능 모니터링**: 수정 후 성능 측정

### C. MCP 접근 제한 해결 (지침 준수)
1. **오류 패턴 분석**: MCP 경로 제한 문제 학습
2. **대안 전략 구현**: 기본 도구 사용시 자동 기록
3. **해결책 문서화**: 향후 유사 문제 대비

## 📊 예상 결과

### 성공 지표
- **테스트 통과율**: 73% → 95% 이상
- **오류 학습 패턴**: 10개 이상 기록
- **지침 준수율**: 100%

### 시간 계획
- **1시간**: 통합 테스트 수정
- **30분**: 레이아웃 문제 해결
- **30분**: 문서화 및 학습 기록

## 🎯 다음 세션 목표

1. **KIRO v4.0 지침 100% 준수**
2. **모든 오류를 학습 시스템에 기록**
3. **베이킹 계산기 Phase 2 완성도 95% 달성**
4. **효율성 대시보드 완전 활용**

---

**🚨 중요: 이제부터 모든 작업은 KIRO v4.0 지침을 엄격히 준수하여 진행합니다!**