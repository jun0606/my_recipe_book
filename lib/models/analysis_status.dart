/// 분석 상태 열거형
enum AnalysisStatus {
  pending('대기 중'),
  processing('처리 중'),
  completed('완료'),
  partiallyCompleted('부분 완료'),
  failed('실패'),
  partial_failure('부분 실패'), // Added partial_failure
  cancelled('취소됨'),
  timeout('시간 초과');

  const AnalysisStatus(this.displayName);

  final String displayName;

  /// 성공적인 상태인지 확인
  bool get isSuccessful => this == completed || this == partiallyCompleted;

  /// 실패한 상태인지 확인
  bool get isFailed => this == failed || this == timeout;

  /// 진행 중인 상태인지 확인
  bool get isInProgress => this == pending || this == processing;

  /// 완료된 상태인지 확인 (성공/실패 무관)
  bool get isFinished => !isInProgress && this != cancelled;
}
