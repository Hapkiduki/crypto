import 'package:core/src/result.dart';
import 'package:flutter/foundation.dart';

abstract interface class BaseCommand<T> {
  /// A [ValueListenable] that notifies listeners when the result changes.
  ValueListenable<Result<T>?> get resultNotifier;
}
