# Kiro Workspace Duplicate File Cleanup Script

Write-Host "Kiro Workspace Duplicate File Cleanup Started" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Gray

# Files to remove (duplicates and unnecessary files)
$FilesToRemove = @{
    # Version duplicates
    "gemini_cli_kiro_integration.md" = "v2 version exists"
    "kiro_guidelines_updated v1.md" = "v2 version exists"
    
    # Feature duplicates
    "refactoring_plan.md" = "detailed version exists"
    "safe_refactoring_strategy.md" = "implementation_plan exists"
    "gemini_setup_guide.md" = "complete_guide exists"
    "kiro_gemini_usage_guide.md" = "complete_guide exists"
    
    # MCP related duplicates
    "mcp_connection_report.md" = "final_recommendation exists"
    "mcp_enhancement_strategy.md" = "final_recommendation exists"
    "mcp_test_moved.txt" = "temporary file"
    "test_enhanced_mcp.md" = "complete_setup exists"
    
    # Temporary/backup files
    "main.dart.bak" = "backup file"
    "tatus" = "typo file"
    "gemini_work_log.md" = "temporary log"
    "version_history.md" = "unnecessary history"
    
    # Batch file duplicates
    "auto_setup_gemini.bat" = "replaced by PowerShell"
    "backup_gemini_config.bat" = "replaced by PowerShell"
    "copy_guide.bat" = "unnecessary"
    "copy_hallucination_guide.bat" = "unnecessary"
    "detect_project_type.bat" = "unnecessary"
    "restore_gemini_config.bat" = "replaced by PowerShell"
    "start_gemini.bat" = "replaced by PowerShell"
    "sync_project_docs.bat" = "replaced by PowerShell"
    "update_gemini_backup.bat" = "replaced by PowerShell"
    
    # Duplicate documents
    "next_steps_action_plan.md" = "included in complete_guide"
    "refactoring_checklist.md" = "included in implementation_plan"
    "screens_and_navigation.md" = "included in app_structure"
}

# Files to merge (combine content into one file)
$FilesToMerge = @{
    "ai_guide.md" = @("ai_context_optimization_guide.md", "ai_code_modification_guidelines.md", "ai_hallucination_prevention_guide.md")
    "project_docs.md" = @("project_documentation_guidelines.md", "document_update_guide.md", "documentation_index.md")
    "development_complete_guide.md" = @("development_guidelines.md", "code_quality_guidelines.md", "testing_documentation.md")
}

# 1. Remove duplicate files
Write-Host "Step 1: Remove duplicate files" -ForegroundColor Yellow
$RemovedCount = 0

foreach ($File in $FilesToRemove.GetEnumerator()) {
    if (Test-Path $File.Key) {
        try {
            Remove-Item $File.Key -Force
            Write-Host "  Removed: $($File.Key) - $($File.Value)" -ForegroundColor Green
            $RemovedCount++
        } catch {
            Write-Host "  Failed to remove: $($File.Key) - $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  Not found: $($File.Key)" -ForegroundColor Gray
    }
}

Write-Host "  Total $RemovedCount files removed" -ForegroundColor Cyan

# 2. Merge related files
Write-Host "`nStep 2: Merge related files" -ForegroundColor Yellow
$MergedCount = 0

foreach ($Target in $FilesToMerge.GetEnumerator()) {
    $MergedContent = @()
    $MergedContent += "# $($Target.Key.Replace('.md', '').Replace('_', ' ').ToUpper())"
    $MergedContent += ""
    $MergedContent += "This document is a merge of the following files:"
    
    $SourceFiles = @()
    foreach ($SourceFile in $Target.Value) {
        if (Test-Path $SourceFile) {
            $MergedContent += "- $SourceFile"
            $SourceFiles += $SourceFile
        }
    }
    
    $MergedContent += ""
    $MergedContent += "---"
    $MergedContent += ""
    
    # Add content from each source file
    foreach ($SourceFile in $SourceFiles) {
        if (Test-Path $SourceFile) {
            $MergedContent += "## $($SourceFile.Replace('.md', '').Replace('_', ' ').ToUpper())"
            $MergedContent += ""
            $Content = Get-Content $SourceFile -Encoding UTF8
            $MergedContent += $Content
            $MergedContent += ""
            $MergedContent += "---"
            $MergedContent += ""
        }
    }
    
    # Create merged file
    if ($SourceFiles.Count -gt 0) {
        $MergedContent | Out-File $Target.Key -Encoding UTF8
        Write-Host "  Merged: $($Target.Key) ($($SourceFiles.Count) files)" -ForegroundColor Green
        
        # Remove original files
        foreach ($SourceFile in $SourceFiles) {
            Remove-Item $SourceFile -Force
            Write-Host "    Removed original: $SourceFile" -ForegroundColor Gray
        }
        
        $MergedCount++
    }
}

Write-Host "  Total $MergedCount file groups merged" -ForegroundColor Cyan

# 3. Generate core files list
Write-Host "`nStep 3: Generate core files list" -ForegroundColor Yellow

$CoreFiles = @{
    "Start and Control" = @(
        "kiro_autostart.bat",
        "kiro_init.ps1",
        "kiro_startup_automation.ps1",
        "kiro_gemini_master_control.ps1",
        "gemini_obedience_enforcer.ps1"
    )
    "Monitoring" = @(
        "gemini_usage_monitor.ps1",
        "gemini_consistency_enforcer.ps1",
        "verify_gemini_obedience.ps1"
    )
    "Guides and Settings" = @(
        "KIRO_MASTER_GUIDE.md",
        "kiro_gemini_complete_guide.md",
        "gemini_cli_obedience_guide.md",
        "gemini_obedience_usage.md",
        "kiro_guidelines_updated_v2.md"
    )
    "MCP and Configuration" = @(
        ".kiro/settings/mcp.json",
        "C:/Users/junlyn/.gemini/settings.json",
        "mcp_final_recommendation.md",
        "mcp_complete_setup.md"
    )
    "Project Documents" = @(
        "ai_guide.md",
        "project_docs.md", 
        "development_complete_guide.md",
        "README.md"
    )
}

$CoreFilesList = @()
$CoreFilesList += "# KIRO Core Files List"
$CoreFilesList += ""
$CoreFilesList += "Core files remaining after cleanup."
$CoreFilesList += ""

foreach ($Category in $CoreFiles.GetEnumerator()) {
    $CoreFilesList += "## $($Category.Key)"
    $CoreFilesList += ""
    foreach ($File in $Category.Value) {
        if (Test-Path $File) {
            $CoreFilesList += "- [x] $File"
        } else {
            $CoreFilesList += "- [ ] $File (missing)"
        }
    }
    $CoreFilesList += ""
}

$CoreFilesList += "## Cleanup Results"
$CoreFilesList += ""
$CoreFilesList += "- Removed files: $RemovedCount"
$CoreFilesList += "- Merged file groups: $MergedCount"
$CoreFilesList += "- Cleanup completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

$CoreFilesList | Out-File "kiro_core_files.md" -Encoding UTF8
Write-Host "  Core files list generated: kiro_core_files.md" -ForegroundColor Green

# 4. Completion report
Write-Host "`nCleanup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Gray
Write-Host "Cleanup Results:" -ForegroundColor Cyan
Write-Host "  • Removed duplicate files: $RemovedCount" -ForegroundColor White
Write-Host "  • Merged file groups: $MergedCount" -ForegroundColor White
Write-Host "  • Core files list: kiro_core_files.md generated" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Run .\kiro_init.ps1 to prepare Kiro startup" -ForegroundColor White
Write-Host "  2. Check kiro_core_files.md to review remaining files" -ForegroundColor White
Write-Host "  3. Proceed with additional cleanup if needed" -ForegroundColor White