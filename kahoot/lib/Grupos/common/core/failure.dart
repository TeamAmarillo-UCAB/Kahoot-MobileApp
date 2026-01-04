abstract class Failure {
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}

// Fallo genérico de Servidor
class ServerFailure extends Failure {
  ServerFailure([String message = "Ha ocurrido un error en el servidor"])
    : super(message);
}

// Fallo de Conexión
class ConnectionFailure extends Failure {
  ConnectionFailure([String message = "No hay conexión a internet"])
    : super(message);
}

// Fallo genérico (para catch-all)
class GeneralFailure extends Failure {
  GeneralFailure(String message) : super(message);
}
