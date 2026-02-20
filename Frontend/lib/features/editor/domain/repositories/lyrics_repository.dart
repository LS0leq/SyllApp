

abstract class LyricsRepository {
  
  Future<String?> openFile();
  
  
  
  Future<bool> saveFile(String content, {String? filePath});
  
  
  Future<String?> pickDirectory();
  
  
  Future<List<dynamic>> getFilesInDirectory(String path);
  
  
  Future<String?> readFile(String path);
}
