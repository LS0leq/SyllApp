




export 'native_file_utils_stub.dart'
    if (dart.library.io) 'native_file_utils_native.dart'
    if (dart.library.html) 'native_file_utils_web.dart';
