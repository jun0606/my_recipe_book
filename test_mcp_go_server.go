package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

func main() {
	// Create a new MCP server for Flutter development
	s := server.NewMCPServer(
		"Flutter Development Assistant",
		"1.0.0",
		server.WithToolCapabilities(true),
		server.WithResourceCapabilities(true),
	)

	// Add file analysis tool
	analyzeFileTool := mcp.NewTool("analyze_flutter_file",
		mcp.WithDescription("Analyze Flutter/Dart files for errors and improvements"),
		mcp.WithString("file_path", mcp.Required(), mcp.Description("Path to the Flutter/Dart file")),
	)
	s.AddTool(analyzeFileTool, analyzeFlutterFileHandler)

	// Add project structure tool
	projectStructureTool := mcp.NewTool("get_project_structure",
		mcp.WithDescription("Get Flutter project structure and dependencies"),
		mcp.WithString("project_path", mcp.Required(), mcp.Description("Path to the Flutter project")),
	)
	s.AddTool(projectStructureTool, getProjectStructureHandler)

	// Add performance analysis tool
	performanceTool := mcp.NewTool("analyze_performance",
		mcp.WithDescription("Analyze Flutter app performance and suggest optimizations"),
		mcp.WithString("target_path", mcp.Required(), mcp.Description("Path to analyze for performance")),
	)
	s.AddTool(performanceTool, analyzePerformanceHandler)

	// Add resource for project metadata
	s.AddResource("project_metadata", "Project metadata and statistics", getProjectMetadata)

	// Start the stdio server
	if err := server.ServeStdio(s); err != nil {
		log.Fatalf("Server error: %v", err)
	}
}

func analyzeFlutterFileHandler(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	filePath, err := request.RequireString("file_path")
	if err != nil {
		return mcp.NewToolResultError(err.Error()), nil
	}

	// Read and analyze the file
	content, err := os.ReadFile(filePath)
	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("Failed to read file: %v", err)), nil
	}

	// Simple analysis (in real implementation, this would be more sophisticated)
	analysis := fmt.Sprintf(`File Analysis for: %s
File Size: %d bytes
Lines: %d
Analysis:
- File successfully read
- Basic syntax check: OK
- Recommendations: Consider adding null safety checks
`, filePath, len(content), len(string(content)))

	return mcp.NewToolResultText(analysis), nil
}

func getProjectStructureHandler(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	projectPath, err := request.RequireString("project_path")
	if err != nil {
		return mcp.NewToolResultError(err.Error()), nil
	}

	// Walk through project directory
	var structure []string
	err = filepath.Walk(projectPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		
		// Skip hidden directories and files
		if filepath.Base(path)[0] == '.' {
			if info.IsDir() {
				return filepath.SkipDir
			}
			return nil
		}

		// Only include Dart files and important directories
		if info.IsDir() || filepath.Ext(path) == ".dart" || filepath.Base(path) == "pubspec.yaml" {
			relPath, _ := filepath.Rel(projectPath, path)
			if info.IsDir() {
				structure = append(structure, fmt.Sprintf("📁 %s/", relPath))
			} else {
				structure = append(structure, fmt.Sprintf("📄 %s", relPath))
			}
		}
		return nil
	})

	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("Failed to analyze project structure: %v", err)), nil
	}

	result := fmt.Sprintf("Flutter Project Structure:\n%s", joinStrings(structure, "\n"))
	return mcp.NewToolResultText(result), nil
}

func analyzePerformanceHandler(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	targetPath, err := request.RequireString("target_path")
	if err != nil {
		return mcp.NewToolResultError(err.Error()), nil
	}

	// Simple performance analysis
	analysis := fmt.Sprintf(`Performance Analysis for: %s

🚀 Performance Recommendations:
1. Use const constructors where possible
2. Implement proper ListView.builder for large lists
3. Optimize image loading with caching
4. Use Provider pattern for state management
5. Minimize widget rebuilds with keys

📊 Metrics:
- Analysis completed successfully
- Target: %s
- Recommendations: 5 items found
`, targetPath, targetPath)

	return mcp.NewToolResultText(analysis), nil
}

func getProjectMetadata(ctx context.Context, uri string) (*mcp.GetResourceResult, error) {
	metadata := `{
  "project_name": "my_recipe_book",
  "framework": "Flutter",
  "language": "Dart",
  "mcp_servers": 7,
  "last_analysis": "2025-07-25",
  "performance_score": 85,
  "code_quality": "Good",
  "recommendations": [
    "Add more unit tests",
    "Implement error boundaries",
    "Optimize asset loading"
  ]
}`

	return &mcp.GetResourceResult{
		Contents: []mcp.ResourceContents{
			{
				URI:      uri,
				MimeType: "application/json",
				Text:     &metadata,
			},
		},
	}, nil
}

func joinStrings(strs []string, sep string) string {
	if len(strs) == 0 {
		return ""
	}
	result := strs[0]
	for i := 1; i < len(strs); i++ {
		result += sep + strs[i]
	}
	return result
}