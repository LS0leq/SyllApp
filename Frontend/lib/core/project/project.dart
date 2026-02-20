
enum SyncStatus {
  
  local,

  
  synced,

  
  modified,

  
  conflict,
}


class Project {
  final String name;
  final String path;
  final DateTime created;
  final DateTime lastOpened;

  
  final String? cloudId;

  
  final SyncStatus syncStatus;

  Project({
    required this.name,
    required this.path,
    required this.created,
    required this.lastOpened,
    this.cloudId,
    this.syncStatus = SyncStatus.local,
  });

  
  Project copyWithLastOpened(DateTime lastOpened) {
    return Project(
      name: name,
      path: path,
      created: created,
      lastOpened: lastOpened,
      cloudId: cloudId,
      syncStatus: syncStatus,
    );
  }

  
  Project copyWith({
    String? name,
    String? path,
    DateTime? created,
    DateTime? lastOpened,
    String? Function()? cloudId,
    SyncStatus? syncStatus,
  }) {
    return Project(
      name: name ?? this.name,
      path: path ?? this.path,
      created: created ?? this.created,
      lastOpened: lastOpened ?? this.lastOpened,
      cloudId: cloudId != null ? cloudId() : this.cloudId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  
  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'created': created.toIso8601String(),
        'lastOpened': lastOpened.toIso8601String(),
        if (cloudId != null) 'cloudId': cloudId,
        'syncStatus': syncStatus.name,
      };

  
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'] as String,
      path: json['path'] as String,
      created: DateTime.parse(json['created'] as String),
      lastOpened: DateTime.parse(json['lastOpened'] as String),
      cloudId: json['cloudId'] as String?,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == (json['syncStatus'] as String?),
        orElse: () => SyncStatus.local,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}
