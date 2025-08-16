-- 프로젝트 메타데이터 데이터베이스 초기화

-- 파일 메타데이터 테이블
CREATE TABLE IF NOT EXISTS file_metadata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_path TEXT UNIQUE NOT NULL,
    file_type TEXT NOT NULL,
    size_bytes INTEGER,
    last_modified DATETIME,
    git_hash TEXT,
    complexity_score INTEGER,
    token_count INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 코드 분석 결과 테이블
CREATE TABLE IF NOT EXISTS code_analysis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_path TEXT NOT NULL,
    analysis_type TEXT NOT NULL, -- 'error', 'warning', 'suggestion'
    message TEXT NOT NULL,
    line_number INTEGER,
    severity INTEGER, -- 1-5 scale
    resolved BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (file_path) REFERENCES file_metadata(file_path)
);

-- 작업 세션 기록 테이블
CREATE TABLE IF NOT EXISTS work_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_start DATETIME NOT NULL,
    session_end DATETIME,
    files_modified TEXT, -- JSON array of file paths
    tasks_completed TEXT, -- JSON array of task descriptions
    token_usage INTEGER,
    success_rate REAL, -- 0.0 to 1.0
    notes TEXT
);

-- MCP 사용 통계 테이블
CREATE TABLE IF NOT EXISTS mcp_usage_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mcp_server TEXT NOT NULL,
    operation TEXT NOT NULL,
    execution_time_ms INTEGER,
    success BOOLEAN,
    error_message TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 프로젝트 설정 테이블
CREATE TABLE IF NOT EXISTS project_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 초기 설정 데이터 삽입
INSERT OR REPLACE INTO project_settings (key, value) VALUES 
('project_name', 'my_recipe_book'),
('main_language', 'dart'),
('framework', 'flutter'),
('mcp_version', '2.0'),
('last_optimization', datetime('now'));

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_file_metadata_path ON file_metadata(file_path);
CREATE INDEX IF NOT EXISTS idx_code_analysis_file ON code_analysis(file_path);
CREATE INDEX IF NOT EXISTS idx_mcp_stats_server ON mcp_usage_stats(mcp_server);
CREATE INDEX IF NOT EXISTS idx_sessions_start ON work_sessions(session_start);