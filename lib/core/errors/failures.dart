import 'package:equatable/equatable.dart';

/// Base failure class for clean architecture error handling
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

class NotificationFailure extends Failure {
  const NotificationFailure([super.message = 'Notification operation failed']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}
