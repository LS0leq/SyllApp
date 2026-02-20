import '../../domain/repositories/lyrics_repository.dart';





class LyricsRepositoryWeb implements LyricsRepository {
  @override
  Future<String?> openFile() async {
    
    return null;
  }

  @override
  Future<bool> saveFile(String content, {String? filePath}) async {
    
    return false;
  }

  @override
  Future<String?> pickDirectory() async {
    return null;
  }

  @override
  Future<List<dynamic>> getFilesInDirectory(String path) async {
    return [];
  }

  @override
  Future<String?> readFile(String path) async {
    return null;
  }
}
