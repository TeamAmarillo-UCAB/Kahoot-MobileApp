class Result<T> {
  final T? _value;
  final Exception? _error;
  final bool _isSuccess;

  const Result._(this._value, this._error, this._isSuccess);

  static Result<void> voidSuccess() => Result._(null, null, true);

  bool isSuccessful() => _isSuccess;

  T getValue() {
    if (!_isSuccess) throw _error!;
    return _value!;
  }

  Exception getError() {
    if (_isSuccess) throw Exception('Result is successful');
    return _error!;
  }

  factory Result.success(T value) => Result._(value, null, true);

  factory Result.makeError(Exception error) => Result._(null, error, false);
}
