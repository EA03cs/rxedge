import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/flavor_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Default to dev flavor when running `flutter run` directly
  FlavorConfig.initialize(
    flavor: AppFlavor.dev,
    appName: 'RxEdge (Dev)',
    apiBaseUrl: 'https://api-dev.rxedge.internal/v1',
    enableLogging: true,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: RxEdgeApp(),
    ),
  );
}
