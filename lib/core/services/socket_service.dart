import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../features/challenges/presentation/controllers/challenges_controller.dart';
import '../../features/feedback/presentation/controllers/feedback_controller.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/library/presentation/controllers/library_controller.dart';
import '../../features/notifications/presentation/controllers/notifications_controller.dart';
import '../config/app_constants.dart';
import '../config/env_config.dart';
import '../config/flavor_config.dart';
import '../localization/app_locale_provider.dart';
import '../storage/secure_storage_service.dart';
import 'logger_service.dart';

/// Real-time Socket.IO client service connected to `D:\Backend\rxedge\src\Utils\Socket\index.js`.
/// Automatically invalidates user-facing controllers when the backend emits live events.
class SocketService {
  final Ref _ref;
  final SecureStorageService _secureStorage;

  io.Socket? _socket;
  String? _connectedToken;
  bool _disposed = false;

  SocketService({
    required Ref ref,
    required SecureStorageService secureStorage,
  })  : _ref = ref,
        _secureStorage = secureStorage;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connectIfAuthenticated() async {
    if (_disposed || !FlavorConfig.isInitialized) return;

    String? token;
    try {
      token = await _secureStorage.read(AppConstants.keyAuthToken);
    } catch (_) {
      return;
    }
    if (token == null || token.isEmpty || _disposed) return;

    if (_socket != null && _connectedToken == token) {
      if (!isConnected) {
        _socket!.connect();
      }
      return;
    }

    disconnect();
    _connectedToken = token;

    final langCode = _ref.read(localeProvider).languageCode;
    final origin = EnvConfig.serverOrigin;

    final socket = io.io(
      origin,
      io.OptionBuilder()
          .setTransports(<String>['websocket', 'polling'])
          .disableAutoConnect()
          .enableReconnection()
          .setAuth(<String, dynamic>{
            'token': token,
            'lang': langCode,
          })
          .setExtraHeaders(<String, String>{
            'Accept-Language': langCode,
          })
          .build(),
    );

    socket.onConnect((_) {
      AppLogger.i('Socket.IO connected to $origin', tag: 'Socket');
    });

    socket.onConnectError((dynamic err) {
      AppLogger.w('Socket.IO connection error: $err', tag: 'Socket');
    });

    socket.on('feedback:updated', (_) {
      if (_disposed) return;
      _ref.invalidate(feedbackListControllerProvider);
      _ref.invalidate(notificationsControllerProvider);
      _ref.invalidate(homeControllerProvider);
    });

    socket.on('notification:new', (_) {
      if (_disposed) return;
      _ref.invalidate(notificationsControllerProvider);
      _ref.invalidate(homeControllerProvider);
    });

    socket.on('material:new', (_) {
      if (_disposed) return;
      _ref.invalidate(libraryControllerProvider);
      _ref.invalidate(homeControllerProvider);
    });

    socket.on('challenge:updated', (_) {
      if (_disposed) return;
      _ref.invalidate(challengesControllerProvider);
      _ref.invalidate(homeControllerProvider);
    });

    _socket = socket;
    socket.connect();
  }

  void disconnect() {
    _connectedToken = null;
    final current = _socket;
    _socket = null;
    if (current != null) {
      try {
        current.clearListeners();
        current.disconnect();
        current.dispose();
      } catch (_) {}
    }
  }

  void dispose() {
    _disposed = true;
    disconnect();
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final service = SocketService(ref: ref, secureStorage: secureStorage);
  ref.onDispose(service.dispose);
  return service;
});
