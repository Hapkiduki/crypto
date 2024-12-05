import 'package:core/core.dart';
import 'package:core/src/base_command.dart';
import 'package:flutter/widgets.dart';

/// Configuration class for a command listener.
///
/// Contains the command to listen to and the corresponding listener callback.
class CommandListenerConfig {
  /// Creates a [CommandListenerConfig] with the specified [command] and [listener].
  const CommandListenerConfig({
    required this.command,
    required this.listener,
  });

  /// The command to listen to, implementing `BaseCommand<dynamic>`.
  final BaseCommand<dynamic> command;

  /// Callback executed when the command's result changes.
  final void Function(BuildContext context, Result<dynamic>? result) listener;
}

/// A widget that listens to multiple commands and executes callbacks when their results change.
///
/// This widget helps in managing multiple [BaseCommand] instances and their corresponding listeners.
/// It listens to the `resultNotifier` of each command and invokes the provided listener callback
/// whenever the result changes.

class CommandListener extends StatefulWidget {
  /// Creates a [CommandListener] that listens to a list of [CommandListenerConfig].
  const CommandListener({
    required this.listeners,
    required this.child,
    super.key,
  });

  /// A list of [CommandListenerConfig] containing the commands and their listeners.
  final List<CommandListenerConfig> listeners;

  /// The child widget to display.
  final Widget child;

  @override
  State<CommandListener> createState() => _CommandListenerState();
}

class _CommandListenerState extends State<CommandListener> {
  /// A map to keep track of the commands and their associated listener callbacks.
  final Map<BaseCommand<dynamic>, VoidCallback> _listeners = {};

  @override
  void initState() {
    super.initState();
    _addListeners(widget.listeners);
  }

  @override
  void didUpdateWidget(covariant CommandListener oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldCommands = oldWidget.listeners.map((e) => e.command).toSet();
    final newCommands = widget.listeners.map((e) => e.command).toSet();

    // Commands that have been removed.
    final removedCommands = oldCommands.difference(newCommands);
    // Commands that have been added.
    final addedCommands = newCommands.difference(oldCommands);

    // Remove listeners for commands that are no longer present.
    for (final command in removedCommands) {
      final listener = _listeners[command];
      if (listener != null) {
        command.resultNotifier.removeListener(listener);
        _listeners.remove(command);
      }
    }

    // Add listeners for new commands.
    for (final config in widget.listeners) {
      if (addedCommands.contains(config.command)) {
        _addListener(config);
      }
    }
  }

  @override
  void dispose() {
    _removeAllListeners();
    super.dispose();
  }

  /// Adds listeners for the provided list of [CommandListenerConfig].
  void _addListeners(List<CommandListenerConfig> configs) {
    for (final config in configs) {
      _addListener(config);
    }
  }

  /// Adds a listener for a single [CommandListenerConfig].
  void _addListener(CommandListenerConfig config) {
    void listener() => _onResultEmitted(config);
    config.command.resultNotifier.addListener(listener);
    _listeners[config.command] = listener;
  }

  /// Removes all listeners and clears the listener map.
  void _removeAllListeners() {
    _listeners
      ..forEach((command, listener) {
        command.resultNotifier.removeListener(listener);
      })
      ..clear();
  }

  /// Callback invoked when a command's result changes.
  void _onResultEmitted(CommandListenerConfig config) {
    config.listener(context, config.command.resultNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    // Return the child without rebuilding when results change.
    return widget.child;
  }
}
