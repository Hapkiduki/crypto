import 'dart:async';
import 'package:core/src/result.dart';
import 'package:flutter/foundation.dart';

/// {@template stream_command}
/// A class that facilitates interaction with a StreamUseCase.
///
/// It encapsulates a stream action, exposes its current data and error states,
/// and ensures proper subscription management.
///
/// Actions must return a [Stream] of [Result].
///
/// Use [StreamCommand] for actions that require parameters.
/// For actions without parameters, use [NoParams] as the type for [Params].
///
/// Consume the action result by listening to [isListening] and [latestResult],
/// and handle the states accordingly.
/// {@endtemplate}
class StreamCommand<T, Params> {
  /// {@macro stream_command}
  StreamCommand(this._action);

  /// The stream action to be executed.
  ///
  /// The [action] is a function that takes [Params] and returns a [Stream<Result<T>>].
  final Stream<Result<T>> Function(Params) _action;

  /// {@template is_listening}
  /// Indicates whether the stream is currently active.
  ///
  /// This is a [ValueNotifier] that notifies listeners when the listening state changes.
  /// {@endtemplate}
  final ValueNotifier<bool> isListening = ValueNotifier<bool>(false);

  /// {@template latest_result}
  /// The latest result emitted by the stream.
  ///
  /// This is a [ValueNotifier] that notifies listeners when a new result is available.
  /// {@endtemplate}
  final ValueNotifier<Result<T>?> latestResult = ValueNotifier<Result<T>?>(null);

  StreamSubscription<Result<T>>? _subscription;

  /// {@template start}
  /// Starts listening to the stream with the given [params].
  ///
  /// If already listening, this method does nothing.
  /// After starting, it updates [isListening] and notifies listeners of new results.
  /// {@endtemplate}
  void start(Params params) {
    if (isListening.value) return;

    isListening.value = true;

    _subscription = _action(params).listen(
      (result) {
        latestResult.value = result;
      },
      onError: (Object error, StackTrace? stackTrace) {
        latestResult.value = Error<T>(
          Failure(
            message: 'Stream error occurred.',
            exception: error,
            stackTrace: stackTrace,
          ),
        );
      },
      onDone: () {
        isListening.value = false;
      },
    );
  }

  /// {@template stop}
  /// Stops listening to the stream and cancels the subscription.
  ///
  /// Updates [isListening] accordingly.
  /// {@endtemplate}
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    isListening.value = false;
  }

  /// {@template dispose}
  /// Disposes the [isListening] and [latestResult] [ValueNotifier]s and cancels the subscription.
  ///
  /// Call this method when the [StreamCommand] is no longer needed to free up resources.
  /// {@endtemplate}
  void dispose() {
    stop();
    isListening.dispose();
    latestResult.dispose();
  }
}
