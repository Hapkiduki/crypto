import 'package:core/src/result.dart';
import 'package:flutter/foundation.dart';

/// {@template command}
/// A class that facilitates interaction with a ViewModel or UseCase.
///
/// It encapsulates an asynchronous action (typically a UseCase),
/// exposes its execution state via [isExecuting], and provides the [result]
/// of the action once it completes.
///
/// It ensures that the action cannot be launched again until it finishes.
///
/// Actions must return a [Result] wrapped in a [Future].
///
/// Use [Command] for actions that require parameters.
/// For actions without parameters, use [NoParams] as the type for [Params].
///
/// Consume the action result by listening to [isExecuting] and [result],
/// and handle the states accordingly.
/// {@endtemplate}
class Command<T, Params> {
  /// {@macro command}
  Command(this._action);

  /// The asynchronous action to be executed.
  ///
  /// The [action] is a function that takes [Params] and returns a [Future<Result<T>>].
  final Future<Result<T>> Function(Params) _action;

  /// {@template is_executing}
  /// Indicates whether the action is currently executing.
  ///
  /// This is a [ValueNotifier] that notifies listeners when the execution state changes.
  /// {@endtemplate}
  final ValueNotifier<bool> isExecuting = ValueNotifier<bool>(false);

  /// {@template result}
  /// The result of the last executed action.
  ///
  /// This is a [ValueNotifier] that notifies listeners when a new result is available.
  /// The [result] will be `null` when no action has been executed yet or when the
  /// result has been cleared.
  /// {@endtemplate}
  final ValueNotifier<Result<T>?> result = ValueNotifier<Result<T>?>(null);

  /// {@template execute}
  /// Executes the action with the given [params].
  ///
  /// If the action is already executing, this method does nothing.
  /// After execution, it updates [isExecuting] and [result] accordingly.
  ///
  /// Listeners of [isExecuting] and [result] will be notified of changes.
  /// {@endtemplate}
  Future<void> execute(Params params) async {
    // Prevent multiple simultaneous executions.
    if (isExecuting.value) return;

    isExecuting.value = true;
    result.value = null;

    try {
      final res = await _action(params);
      result.value = res;
    } finally {
      isExecuting.value = false;
    }
  }

  /// {@template dispose}
  /// Disposes the [isExecuting] and [result] [ValueNotifier]s.
  ///
  /// Call this method when the [Command] is no longer needed to free up resources.
  /// {@endtemplate}
  void dispose() {
    isExecuting.dispose();
    result.dispose();
  }
}
