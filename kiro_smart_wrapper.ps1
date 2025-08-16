# 🧠 KIRO v4.0 스마트 명령어 래퍼 구현
# KIRO_MASTER_GUIDE.md 지침 준수

function Invoke-KiroCommand {
    param(
        [string]$Command,
        [hashtable]$Parameters = @{},
        [string]$ErrorContext = ""
    )
    
    $StartTime = Get-Date
    Write-Host "🤖 KIRO v4.0 스마트 실행: $Command" -ForegroundColor Cyan
    
    try {
        # 크로스 플랫폼 경로 처리
        if ($Parameters.ContainsKey("path")) {
            $Parameters.path = Get-CrossPlatformPath -Path $Parameters.path
        }
        
        # MCP 우선 사용 원칙 적용
        switch ($Command) {
            "readFile" {
                Write-Host "📖 MCP Filesystem 우선 사용" -ForegroundColor Green
                return mcp_filesystem_read_file -path $Parameters.path
            }
            "listDirectory" {
                Write-Host "📁 MCP Filesystem 우선 사용" -ForegroundColor Green
                return mcp_filesystem_list_directory -path $Parameters.path
            }
            "writeFile" {
                Write-Host "✍️ MCP Filesystem 우선 사용" -ForegroundColor Green
                return mcp_filesystem_write_file -path $Parameters.path -content $Parameters.content
            }
            default {
                # 기본 명령어 실행
                $Result = & $Command @Parameters
                return $Result
            }
        }
        
    } catch {
        $ErrorType = $_.Exception.GetType().Name
        $ErrorMessage = $_.Exception.Message
        $FilePath = if ($Parameters.path) { $Parameters.path } else { "N/A" }
        
        Write-Host "🚨 오류 감지 - KIRO v4.0 스마트 복구 시작" -ForegroundColor Red
        
        # 오류 패턴 기록 (지침 준수)
        Record-ErrorPattern -ErrorType $ErrorType -ErrorMessage $ErrorMessage -ErrorContext $ErrorContext -FilePath $FilePath -ToolUsed $Command
        
        # 유사 오류 해결책 검색
        $Solution = Get-ErrorSolution -ErrorType $ErrorType -ErrorMessage $ErrorMessage -FilePath $FilePath -ToolUsed $Command
        
        if ($Solution.Found) {
            Write-Host "✅ 학습된 해결책 적용: $($Solution.Method)" -ForegroundColor Green
            try {
                if ($Solution.Code) {
                    Invoke-Expression $Solution.Code
                }
                # 원래 명령어 재시도
                $RetryResult = & $Command @Parameters
                
                # 성공 기록
                $EndTime = Get-Date
                $ResolutionTime = ($EndTime - $StartTime).TotalSeconds
                Record-ErrorPattern -ErrorType $ErrorType -ErrorMessage $ErrorMessage -ErrorContext $ErrorContext -FilePath $FilePath -ToolUsed $Command -SolutionMethod $Solution.Method -SolutionCode $Solution.Code -ResolutionTimeSeconds $ResolutionTime
                
                Write-Host "🎉 스마트 복구 성공! (소요 시간: $([Math]::Round($ResolutionTime, 1))초)" -ForegroundColor Green
                return $RetryResult
                
            } catch {
                Write-Host "❌ 학습된 해결책 실패 - 대안 전략 시도" -ForegroundColor Red
                return Execute-FallbackRecovery -ErrorType $ErrorType -ErrorMessage $ErrorMessage -FilePath $FilePath -ToolUsed $Command
            }
        } else {
            Write-Host "🔍 새로운 오류 패턴 - 대안 전략 시도" -ForegroundColor Yellow
            return Execute-FallbackRecovery -ErrorType $ErrorType -ErrorMessage $ErrorMessage -FilePath $FilePath -ToolUsed $Command
        }
    }
}

# 크로스 플랫폼 경로 처리 (지침 준수)
function Get-CrossPlatformPath {
    param($Path, $TargetOS = $null)
    
    if (!$TargetOS) {
        $TargetOS = if ($IsWindows) { "Windows" } elseif ($IsLinux) { "Linux" } elseif ($IsMacOS) { "macOS" } else { "Windows" }
    }
    
    switch ($TargetOS) {
        "Windows" {
            $StandardPath = $Path -replace '/', '\'
            if ($StandardPath -notmatch '^[A-Za-z]:') {
                $StandardPath = Join-Path $PWD $StandardPath
            }
            return $StandardPath
        }
        { $_ -in @("Linux", "macOS") } {
            $StandardPath = $Path -replace '\\', '/'
            if ($StandardPath -notmatch '^/') {
                $StandardPath = "./$StandardPath"
            }
            return $StandardPath
        }
    }
}

Write-Host "✅ KIRO v4.0 스마트 래퍼 로드 완료" -ForegroundColor Green