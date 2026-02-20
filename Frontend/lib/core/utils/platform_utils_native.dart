import 'dart:io' show Platform;



bool get isNativeMobile => Platform.isAndroid || Platform.isIOS;
bool get isNativeDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
bool get isWindows => Platform.isWindows;
bool get isLinux => Platform.isLinux;
bool get isMacOS => Platform.isMacOS;
bool get isAndroid => Platform.isAndroid;
bool get isIOS => Platform.isIOS;
String get pathSeparator => Platform.pathSeparator;
