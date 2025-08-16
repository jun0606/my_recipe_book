@echo off
chcp 65001 >nul

REM Kiro 자동 시작 배치 파일
REM Kiro IDE 시작시 자동으로 실행되어 모든 준비를 완료

echo ========================
echo         KIRO 자동 시작 시스템
echo ========================

REM 현재 디렉토리를 프로젝트 루트로 설정
cd /d "%~dp0"

REM PowerShell 실행 정책 확인 및 설정
powershell -NoProfile -ExecutionPolicy Bypass -Command "if ((Get-ExecutionPolicy) -eq 'Restricted') { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force }" >nul 2>&1

REM Kiro 초기화 스크립트 실행
echo Kiro 초기화 중...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { . .\kiro_init.ps1 -Quick; exit $LASTEXITCODE } catch { exit 1 }" >nul 2>&1
set "RESULT=%ERRORLEVEL%"

REM 결과 확인
if "%RESULT%"=="0" (
    echo Kiro 초기화 성공!
    echo 이제 Kiro IDE에서 작업을 시작할 수 있습니다.
) else (
    echo Kiro 초기화 실패! 에러 코드: %RESULT%
    echo 수동으로 .\kiro_init.ps1 -Quick 을 실행해보세요.
)

echo.
echo 주요 명령어:
echo   - "추천 작업 보여줘" - 현재 상황에 맞는 작업 추천
echo   - "프로젝트 상태 확인해줘" - 전체 프로젝트 상태 점검
echo   - "Gemini CLI 상태 확인해줘" - 사용량 및 설정 확인
echo   - "스펙 목록 보여줘" - 활성 스펙 및 진행 상황

REM 3초 후 자동 종료 (IDE에서 실행시 바로 보이도록)
timeout /t 3 /nobreak >nul