import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/env_config.dart';
import 'core/config/flavor_config.dart';
import 'core/storage/storage_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageInitializer.init();

  FlavorConfig.initialize(
    flavor: AppFlavor.dev,
    appName: 'RxEdge (Dev)',
    apiBaseUrl: EnvConfig.defaultDevBaseUrl,
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
