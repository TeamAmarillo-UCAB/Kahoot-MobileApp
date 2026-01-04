class Result<T> {
  final T? _value;
  final Object? _error;
  final bool _isSuccess;

  // Constructor privado
  Result._(this._value, this._error, this._isSuccess);

  // Factory para caso de Éxito
  factory Result.success(T value) {
    return Result._(value, null, true);
  }

  // Factory para caso de Error (AQUÍ ESTÁ EL MÉTODO QUE BUSCAS)
  factory Result.error(Object error) {
    return Result._(null, error, false);
  }

  // Métodos de ayuda que usa tu Bloc
  bool isSuccessful() => _isSuccess;

  T getValue() {
    if (!_isSuccess)
      throw Exception("No se puede obtener valor de un resultado fallido");
    return _value!;
  }

  Object getError() {
    if (_isSuccess)
      throw Exception("No se puede obtener error de un resultado exitoso");
    return _error!;
  }
}
