import 'package:flutter/widgets.dart';

import 'services/auth_service.dart';
import 'services/database_service.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState super.notifier,
    required this.auth,
    required super.child,
  });

  final AuthService auth;

  static AppState state(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }

  static AuthService authService(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.auth;
  }
}
