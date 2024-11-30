import 'package:core/src/base_command.dart';
import 'package:core/src/result.dart';
import 'package:flutter/widgets.dart';

class CommandListener<T> extends StatefulWidget {
  const CommandListener({
    required this.command,
    required this.listener,
    required this.child,
    super.key,
  });

  /// The command to listen to, implementing `BaseCommand<T>`.
  final BaseCommand<T> command;

  /// Callback executed when the result changes.
  final void Function(BuildContext context, Result<T>? result) listener;

  /// The child widget that will be displayed.
  final Widget child;

  @override
  State<CommandListener<T>> createState() => _CommandListenerState();
}

class _CommandListenerState<T> extends State<CommandListener<T>> {
  @override
  void initState() {
    super.initState();
    widget.command.resultNotifier.addListener(_onResultChanged);
  }

  @override
  void didUpdateWidget(covariant CommandListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.command != widget.command) {
      oldWidget.command.resultNotifier.removeListener(_onResultChanged);
      widget.command.resultNotifier.addListener(_onResultChanged);
    }
  }

  @override
  void dispose() {
    widget.command.resultNotifier.removeListener(_onResultChanged);
    super.dispose();
  }

  void _onResultChanged() {
    widget.listener(context, widget.command.resultNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    // Return the child without rebuilding when latestResult changes
    return widget.child;
  }
}
