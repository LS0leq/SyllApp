
class SyncState {
  
  final bool isSyncing;

  
  final String? error;

  
  final DateTime? lastSyncTime;

  
  final int syncedCount;

  
  final int uploadedCount;

  
  final int downloadedCount;

  
  final int updatedCount;

  
  final String? currentOperation;

  const SyncState({
    this.isSyncing = false,
    this.error,
    this.lastSyncTime,
    this.syncedCount = 0,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.updatedCount = 0,
    this.currentOperation,
  });

  
  int get totalSynced => uploadedCount + downloadedCount + updatedCount;

  SyncState copyWith({
    bool? isSyncing,
    String? Function()? error,
    DateTime? Function()? lastSyncTime,
    int? syncedCount,
    int? uploadedCount,
    int? downloadedCount,
    int? updatedCount,
    String? Function()? currentOperation,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      error: error != null ? error() : this.error,
      lastSyncTime: lastSyncTime != null ? lastSyncTime() : this.lastSyncTime,
      syncedCount: syncedCount ?? this.syncedCount,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      updatedCount: updatedCount ?? this.updatedCount,
      currentOperation: currentOperation != null ? currentOperation() : this.currentOperation,
    );
  }
}
