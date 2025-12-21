class Result<T> {
  final T? _value;
  final Exception? _error;
  final bool _isSuccess;

  /// Constructor privado para forzar el uso de los factory methods
  const Result._(this._value, this._error, this._isSuccess);

  /// Crea un resultado exitoso que no devuelve ningún valor (útil para acciones)
  static Result<void> voidSuccess() => Result._(null, null, true);

  /// Indica si la operación fue exitosa
  bool isSuccessful() => _isSuccess;

  /// Retorna el valor si fue exitoso, de lo contrario lanza la excepción guardada
  T getValue() {
    if (!_isSuccess) throw _error!;
    return _value!;
  }

  /// Retorna la excepción si hubo un error, de lo contrario lanza una excepción genérica
  Exception getError() {
    if (_isSuccess) throw Exception('Result is successful');
    return _error!;
  }

  /// Factory para crear un resultado exitoso con un valor
  factory Result.success(T value) => Result._(value, null, true);

  /// Factory para crear un resultado fallido con una excepción
  factory Result.makeError(Exception error) => Result._(null, error, false);
}
