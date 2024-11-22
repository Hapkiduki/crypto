import 'package:equatable/equatable.dart';

/// {@template result}
/// A sealed class that represents the result of an operation, which can either
/// be a [Success] containing data, or a [Error] containing a [Failure].
///
/// This class uses Dart 3's `sealed` classes to ensure that all possible
/// subtypes are known and handled, enabling exhaustive checks in `switch`
/// statements and pattern matching.
///
/// Use [fold] to handle both success and error cases in a functional style.
/// {@endtemplate}
sealed class Result<T> extends Equatable {
  /// {@macro result}
  const Result();

  /// Applies one of the provided functions based on whether this instance is
  /// a [Success] or an [Error].
  ///
  /// - If this is a [Success], calls [onSuccess] with the success [data].
  /// - If this is an [Error], calls [onError] with the [Failure].
  ///
  /// Returns the result of the called function.
  U fold<U>(
    U Function(T data) onSuccess,
    U Function(Failure failure) onError,
  );

  @override
  List<Object?> get props => [];
}

/// {@template success}
/// A subclass of [Result] that represents a successful operation.
///
/// Contains the [data] returned by the operation.
/// {@endtemplate}
final class Success<T> extends Result<T> {
  /// {@macro success}
  const Success(this.data);

  /// The data returned by the successful operation.
  final T data;

  @override
  U fold<U>(
    U Function(T data) onSuccess,
    U Function(Failure failure) onError,
  ) {
    return onSuccess(data);
  }

  @override
  List<Object?> get props => [data];
}

/// {@template error}
/// A subclass of [Result] that represents a failed operation.
///
/// Contains a [Failure] with detailed error information.
/// {@endtemplate}
final class Error<T> extends Result<T> {
  /// {@macro error}
  const Error(this.failure);

  /// The failure information associated with the error.
  final Failure failure;

  @override
  U fold<U>(
    U Function(T data) onSuccess,
    U Function(Failure failure) onError,
  ) {
    return onError(failure);
  }

  @override
  List<Object?> get props => [failure];
}

/// {@template failure}
/// A class that encapsulates error information for failed operations.
///
/// Provides structured error details, including a message, an optional
/// exception, and an optional stack trace for debugging purposes.
///
/// Extend this class to create specific failure types for different error scenarios.
/// {@endtemplate}
class Failure with EquatableMixin {
  /// {@macro failure}
  const Failure({
    required this.message,
    this.exception,
    this.stackTrace,
  });

  /// A human-readable description of the error.
  final String message;

  /// The exception object associated with the error, if available.
  final Object? exception;

  /// The stack trace associated with the error, useful for debugging.
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

/// {@template network_failure}
/// A [Failure] subclass that represents errors related to network issues.
///
/// Use this class to indicate failures due to connectivity problems, timeouts,
/// or other network-related exceptions.
/// {@endtemplate}
final class NetworkFailure extends Failure {
  /// {@macro network_failure}
  const NetworkFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });
}

/// {@template server_failure}
/// A [Failure] subclass that represents errors returned by a server.
///
/// Use this class to indicate failures due to server-side issues, such as
/// 5xx HTTP status codes or malformed responses.
/// {@endtemplate}
final class ServerFailure extends Failure {
  /// {@macro server_failure}
  const ServerFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });
}

/// {@template validation_failure}
/// A [Failure] subclass that represents errors due to invalid input or data.
///
/// Use this class to indicate failures caused by validation errors, such as
/// missing required fields or invalid formats.
/// {@endtemplate}
final class ValidationFailure extends Failure {
  /// {@macro validation_failure}
  const ValidationFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });
}
