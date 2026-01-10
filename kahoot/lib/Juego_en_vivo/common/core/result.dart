/// Una clase genérica para envolver respuestas de éxito o error.
/// Ayuda a manejar errores de forma funcional en la capa de dominio y aplicación.
class Result<T> {
  final T? _value;
  final Exception? _error;

  // Constructor privado: se accede a través de los factory methods
  Result._(this._value, this._error);

  /// Crea un resultado exitoso con el valor proporcionado.
  factory Result.success(T value) {
    return Result._(value, null);
  }

  /// Crea un resultado de error con una excepción.
  factory Result.makeError(Exception error) {
    return Result._(null, error);
  }

  /// Indica si la operación fue exitosa.
  bool isSuccessful() => _error == null;

  /// Retorna el valor si es exitoso.
  /// Lanza la excepción almacenada si se llama en un estado de error.
  T getValue() {
    if (!isSuccessful()) {
      throw _error!;
    }
    return _value as T;
  }

  /// Retorna la excepción si hubo un error.
  /// Lanza un error de estado si se llama en un resultado exitoso.
  Exception getError() {
    if (isSuccessful()) {
      throw StateError("No se puede obtener el error de un resultado exitoso.");
    }
    return _error!;
  }

  /// Método de utilidad para transformar el valor si es exitoso.
  Result<U> map<U>(U Function(T value) transform) {
    if (isSuccessful()) {
      return Result.success(transform(_value as T));
    } else {
      return Result.makeError(_error!);
    }
  }
}
