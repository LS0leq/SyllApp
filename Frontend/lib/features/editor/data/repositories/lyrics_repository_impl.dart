import '../../domain/repositories/lyrics_repository.dart';
import '../datasources/file_datasource.dart';



class LyricsRepositoryImpl implements LyricsRepository {
  final FileDataSource _dataSource;
  
  LyricsRepositoryImpl({FileDataSource? dataSource}) 
      : _dataSource = dataSource ?? FileDataSource();
  
  @override
  Future<String?> openFile() async {
    return await _dataSource.openFile();
  }
  
  @override
  Future<bool> saveFile(String content, {String? filePath}) async {
    return await _dataSource.saveFile(content, filePath: filePath);
  }
  
  @override
  Future<String?> pickDirectory() async {
    return await _dataSource.pickDirectory();
  }
  
  @override
  Future<List<dynamic>> getFilesInDirectory(String path) async {
    return await _dataSource.getFilesInDirectory(path);
  }
  
  @override
  Future<String?> readFile(String path) async {
    return await _dataSource.readFile(path);
  }
}
