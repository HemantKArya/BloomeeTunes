enum RecoveryReason { automatic, beforeImport, beforeReset }

class RecoveryCopy {
  final String path;
  final DateTime createdAt;
  final RecoveryReason reason;
  const RecoveryCopy(
      {required this.path, required this.createdAt, required this.reason});
}
