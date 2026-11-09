import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/l10n/l10n.dart';
import '../../app/theme/theme.dart';
import 'offline_banner.dart';

/// Top Connectivity Banner managing both offline state and "Back online" toast banner
class ConnectivityBanner extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner> {
  bool _wasOffline = false;
  bool _showBackOnlineToast = false;
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _handleOnlineTransition(bool isOffline) {
    if (_wasOffline && !isOffline) {
      setState(() => _showBackOnlineToast = true);
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showBackOnlineToast = false);
        }
      });
    }
    _wasOffline = isOffline;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final isOffline = ref.watch(isOfflineProvider);

    // Track transition
    if (isOffline != _wasOffline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleOnlineTransition(isOffline);
      });
    }

    return Column(
      children: [
        if (isOffline)
          OfflineBanner(
            message: "Offline mode — displaying cached materials and lessons.",
            isVisible: true,
            onRetry: () {
              ref.read(isOfflineProvider.notifier).state = false;
            },
          )
        else if (_showBackOnlineToast)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: RxSpacing.s16,
              vertical: RxSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: colors.successSoft,
              border: Border(
                bottom: BorderSide(
                  color: colors.success.withValues(alpha: 0.25),
                  width: RxShadows.hairlineBorderWidth,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.checkCheck, size: 16.0, color: colors.success),
                const SizedBox(width: RxSpacing.s8),
                Expanded(
                  child: Text(
                    l10n.offlineBannerConnected,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
