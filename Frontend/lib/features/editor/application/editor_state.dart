import '../domain/entities/lyric.dart';


class EditorState {
  final String content;
  final String? currentFilePath;
  final String? currentFileName;
  final bool isModified;
  final int currentLine;
  final int currentColumn;
  final Lyric lyricModel;
  final bool isFileOpen;
  
  EditorState({
    this.content = '',
    this.currentFilePath,
    this.currentFileName,
    this.isModified = false,
    this.currentLine = 1,
    this.currentColumn = 1,
    this.isFileOpen = false,
    Lyric? lyricModel,
  }) : lyricModel = lyricModel ?? Lyric();

  EditorState copyWith({
    String? content,
    String? Function()? currentFilePath,
    String? Function()? currentFileName,
    bool? isModified,
    int? currentLine,
    int? currentColumn,
    bool? isFileOpen,
    Lyric? lyricModel,
  }) {
    return EditorState(
      content: content ?? this.content,
      currentFilePath: currentFilePath != null ? currentFilePath() : this.currentFilePath,
      currentFileName: currentFileName != null ? currentFileName() : this.currentFileName,
      isModified: isModified ?? this.isModified,
      currentLine: currentLine ?? this.currentLine,
      currentColumn: currentColumn ?? this.currentColumn,
      isFileOpen: isFileOpen ?? this.isFileOpen,
      lyricModel: lyricModel ?? this.lyricModel,
    );
  }
}
