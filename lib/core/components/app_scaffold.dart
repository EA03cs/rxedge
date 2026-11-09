import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'offline_banner.dart';

/// RxEdge Standard App Scaffold
///
/// Features:
/// - Enforces consistent background, app bar, safe area, and offline banner handling
/// - 1px hairline divider below app bar
/// - Offline banner automatically inserted when offline
/// - Clean bottom navigation integration
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool isOffline;
  final String? offlineMessage;
  final VoidCallback? onOfflineRetry;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.isOffline = false,
    this.offlineMessage,
    this.onOfflineRetry,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;

    return Scaffold(
      backgroundColor: backgroundColor ?? colors.background,
      appBar: appBar != null
          ? PreferredSize(
              preferredSize: appBar!.preferredSize + const Offset(0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  appBar!,
                  Divider(
                    height: RxShadows.hairlineBorderWidth,
                    thickness: RxShadows.hairlineBorderWidth,
                    color: colors.border,
                  ),
                ],
              ),
            )
          : null,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        top: appBar == null && safeAreaTop,
        bottom: bottomNavigationBar == null && safeAreaBottom,
        child: Column(
          children: [
            if (isOffline)
              OfflineBanner(
                message: offlineMessage,
                onRetry: onOfflineRetry,
              ),
            Expanded(child: body),
          ],
        ),
      ),
      bottomSheet: bottomSheet,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
