import 'dart:io';



Future<String?> readNativeFile(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  } catch (e) {
    return null;
  }
}

Future<bool> nativeFileExists(String path) async {
  return await File(path).exists();
}

Future<bool> nativeDirectoryExists(String path) async {
  return await Directory(path).exists();
}

Future<void> writeNativeFile(String path, String content) async {
  final file = File(path);
  await file.writeAsString(content);
}





Future<String?> resolveProjectFilePath(String projectPath, String projectName) async {
  final dir = Directory(projectPath);
  if (await dir.exists()) {
    final potentialPath = '$projectPath${Platform.pathSeparator}$projectName.txt';
    final potentialFile = File(potentialPath);
    if (await potentialFile.exists()) {
      return potentialPath;
    }
    return null;
  } else {
    final file = File(projectPath);
    if (await file.exists()) {
      return projectPath;
    }
    return null;
  }
}
