sealed class ServiceException implements Exception {
  const ServiceException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => '$runtimeType($code): $message';
}

class WeddingException extends ServiceException {
  const WeddingException(super.code, super.message);
}

class UserException extends ServiceException {
  const UserException(super.code, super.message);
}

class FavoritesException extends ServiceException {
  const FavoritesException(super.code, super.message);
}

class SelectionException extends ServiceException {
  const SelectionException(super.code, super.message);
}

class ApiException extends ServiceException {
  const ApiException(super.code, super.message);
}
