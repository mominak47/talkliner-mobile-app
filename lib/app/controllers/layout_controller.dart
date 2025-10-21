import 'package:get/get.dart';
import 'package:flutter/widgets.dart';

typedef WidgetHook = Widget Function();

class LayoutController extends GetxController {
  final RxMap<String, Map<String, WidgetHook>> _hooks = <String, Map<String, WidgetHook>>{}.obs;


  void refreshHooks() {
    _hooks.refresh();
  }

  // Register a widget-producing hook to a named action with an ID
  void addAction(String actionName, WidgetHook hook, {String? id}) {
    if (!_hooks.containsKey(actionName)) {
      _hooks[actionName] = {};
    }
    
    // Use provided ID or generate a unique one
    final hookId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _hooks[actionName]![hookId] = hook;
    // _hooks.refresh(); // Trigger update for observers
  }

  // Remove a specific hook by action name and ID
  void removeAction(String actionName, String id) {
    if (_hooks.containsKey(actionName)) {
      _hooks[actionName]!.remove(id);
      if (_hooks[actionName]!.isEmpty) {
        _hooks.remove(actionName);
      }
      _hooks.refresh();
    }
  }

  // Check if a hook exists
  bool hasAction(String actionName, String id) {
    return _hooks.containsKey(actionName) && _hooks[actionName]!.containsKey(id);
  }

  // Call (render) all widgets hooked onto a named action
  List<Widget> doAction(String actionName) {
    if (!_hooks.containsKey(actionName)) return [];
    return _hooks[actionName]!.values.map((hook) => hook()).toList();
  }

  // Clear all hooks for an action name, or clear everything
  void clearHooks([String? actionName]) {
    if (actionName == null) {
      _hooks.clear();
    } else {
      _hooks.remove(actionName);
    }
    _hooks.refresh();
  }
}

// Usage example:
// In your widget tree:
// layoutController.addAction('recent_screen', () => Text('Recent Screen'));
// In your build method:
// layoutController.doAction('recent_screen');