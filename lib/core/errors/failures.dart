import 'package:equatable/equatable.dart';

/// Domain-level failure representation.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'تعذر الاتصال بالخادم. تحقق من الإنترنت.',
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'فشل تسجيل الدخول أو انتهت صلاحية الجلسة.',
  ]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'اسم المستخدم أو كلمة المرور غير صحيحة.',
  ]);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([
    super.message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجدداً.',
  ]);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'ليس لديك صلاحية لتنفيذ هذا الإجراء.',
  ]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'المورد المطلوب غير موجود.']);
}

class ConflictFailure extends Failure {
  const ConflictFailure([
    super.message = 'تعارض في بيانات المورد أو العملية مغلقة مسبقاً.',
  ]);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors = const {}});

  @override
  List<Object?> get props => [message, fieldErrors];
}

class UploadFailure extends Failure {
  const UploadFailure(super.message);
}
