/// Base application exception hierarchy.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppException(this.message, {this.statusCode, this.details});

  @override
  String toString() => '$runtimeType: $message (Status: $statusCode)';
}

/// HTTP 400 — Validation or Model State Errors.
class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    String message =
        'البيانات المدخلة غير صحيحة. يرجى التأكد من الحقول المطلوبة.',
    this.fieldErrors = const {},
    int statusCode = 400,
  }) : super(message, statusCode: statusCode, details: fieldErrors);
}

/// HTTP 401 — Unauthorized or Bad Credentials.
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'اسم المستخدم أو كلمة المرور غير صحيحة / انتهت الجلسة.',
  ]) : super(statusCode: 401);
}

/// HTTP 403 — Forbidden access.
class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'ليس لديك صلاحية للوصول إلى هذا الإجراء أو المورد.',
  ]) : super(statusCode: 403);
}

/// HTTP 404 — Resource not found.
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'المورد المطلوب غير موجود أو تم حذفه.',
  ]) : super(statusCode: 404);
}

/// HTTP 409 — Resource conflict (e.g. email already registered, complaint already closed).
class ConflictException extends AppException {
  const ConflictException([
    super.message = 'تعارض في بيانات المورد أو العملية مغلقة مسبقاً.',
  ]) : super(statusCode: 409);
}

/// HTTP 413 — Payload Too Large (> 5 MB).
class PayloadTooLargeException extends AppException {
  const PayloadTooLargeException([
    super.message = 'حجم الملف يتجاوز الحد الأقصى المسموح به (5 ميجابايت).',
  ]) : super(statusCode: 413);
}

/// HTTP 415 — Unsupported Media Type.
class UnsupportedMediaTypeException extends AppException {
  const UnsupportedMediaTypeException([
    super.message = 'صيغة الملف غير مدعومة. يسمح فقط برفع صور JPG و PNG.',
  ]) : super(statusCode: 415);
}

/// HTTP 429 — Rate Limited.
class RateLimitException extends AppException {
  const RateLimitException([
    super.message =
        'تم تجاوز الحد المسموح من الطلبات. يرجى الانتظار دقيقة والمحاولة لاحقاً.',
  ]) : super(statusCode: 429);
}

/// HTTP 5xx — Internal Server Error.
class ServerException extends AppException {
  const ServerException([
    super.message = 'حدث خطأ غير متوقع في الخادم. يرجى المحاولة في وقت لاحق.',
  ]) : super(statusCode: 500);
}

/// Network transport, connection drop, DNS failure, or timeout.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.',
  ]) : super(statusCode: null);
}

/// Thrown when refresh token rotation is rejected or session is non-recoverable.
class SessionExpiredException extends AppException {
  const SessionExpiredException([
    super.message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجدداً.',
  ]) : super(statusCode: 401);
}

/// Thrown when local secure storage contains invalid or corrupted JSON token data.
class CorruptedTokenRecordException extends AppException {
  const CorruptedTokenRecordException([
    super.message = 'بيانات الجلسة المخزنة تالفة.',
  ]) : super(statusCode: null);
}

/// Thrown when a secure storage write fails.
class StorageWriteException extends AppException {
  const StorageWriteException([
    super.message = 'فشل حفظ بيانات الجلسة في التخزين الآمن.',
  ]) : super(statusCode: null);
}
