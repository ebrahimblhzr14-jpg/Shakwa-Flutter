import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/security/token_manager.dart';
import 'data/mock_data/mock_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core and Auth DI
  await initCoreDependencies();
  await sl<TokenManager>().initialize();

  // Initialize Mock in-memory database with pre-populated records
  MockDatabase.instance.initialize();

  runApp(const ProviderScope(child: ShakwaApp()));
}
