import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';



class FileDataSource {
  
  Future<String?> openFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'rap', 'lyrics'],
        dialogTitle: 'Otwórz plik tekstowy',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      debugPrint('Błąd podczas otwierania pliku: $e');
      return null;
    }
  }

  
  Future<bool> saveFile(String content, {String? filePath}) async {
    try {
      String? path = filePath;
      
      path ??= await FilePicker.platform.saveFile(
        dialogTitle: 'Zapisz plik',
        fileName: 'nowy_tekst.txt',
        type: FileType.custom,
        allowedExtensions: ['txt', 'rap', 'lyrics'],
      );

      if (path != null) {
        final file = File(path);
        await file.writeAsString(content);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Błąd podczas zapisywania pliku: $e');
      return false;
    }
  }

  
  Future<String?> pickDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Wybierz folder projektu',
      );
      return selectedDirectory;
    } catch (e) {
      debugPrint('Błąd podczas wybierania folderu: $e');
      return null;
    }
  }

  
  Future<List<FileSystemEntity>> getFilesInDirectory(String path) async {
    try {
      final directory = Directory(path);
      if (await directory.exists()) {
        return directory
            .listSync()
            .where((entity) =>
                entity is File &&
                (entity.path.endsWith('.txt') ||
                    entity.path.endsWith('.rap') ||
                    entity.path.endsWith('.lyrics')))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Błąd podczas odczytu folderu: $e');
      return [];
    }
  }

  
  Future<String?> readFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      debugPrint('Błąd podczas odczytu pliku: $e');
      return null;
    }
  }
}
