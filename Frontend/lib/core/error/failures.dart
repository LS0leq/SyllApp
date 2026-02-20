

abstract class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  String toString() => message;
}


class FileFailure extends Failure {
  const FileFailure(super.message);
}


class ParseFailure extends Failure {
  const ParseFailure(super.message);
}


class ProjectFailure extends Failure {
  const ProjectFailure(super.message);
}


class AuthFailure extends Failure {
  const AuthFailure(super.message);
}


class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode});
}
