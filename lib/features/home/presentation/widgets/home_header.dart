import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/mentholatum_logo.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';

/// Top Header of the Home Screen matching the executive clinical design:
/// - Corporate Mentholatum Brand Bar (Logo, Language dropdown pill, Notification Bell with red dot, Teal Avatar)
/// - Greeting Row: "Good afternoon, / Ahmed / Keep learning. Keep growing." with 3D Graduation Cap & Books illustration.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _getSalutation(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  String _getInitials(String displayName) {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'RX';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    final displayName = (user?.displayName.trim().isNotEmpty ?? false)
        ? user!.displayName
        : 'Representative';
    final firstName = displayName.split(' ').first;
    final salutation = _getSalutation(context);

    return CustomPaint(
      painter: const _HeaderBackgroundPainter(isArabic: false),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          RxSpacing.s16,
          RxSpacing.s12,
          RxSpacing.s16,
          RxSpacing.s12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Corporate Brand Bar (Mentholatum Logo + Actions)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const MentholatumLogo(height: 25.0),
              const Spacer(),

              // Notification Bell with vibrant red unread dot
              Consumer(
                builder: (context, ref, _) {
                  final unreadCount = ref.watch(unreadNotificationsCountProvider);
                  return InkWell(
                    onTap: () => context.push(AppRoutes.notifications),
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.8),
                          width: RxShadows.hairlineBorderWidth,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4.0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            LucideIcons.bell,
                            size: 17.0,
                            color: colors.textPrimary,
                          ),
                          if (unreadCount > 0)
                            PositionedDirectional(
                              top: 6.0,
                              end: 6.0,
                              child: Container(
                                width: 7.5,
                                height: 7.5,
                                decoration: BoxDecoration(
                                  color: colors.brandRed,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: RxSpacing.s8),

              // Teal Profile Avatar circle (opens Profile)
              InkWell(
                onTap: () => context.push(AppRoutes.profile),
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF005B60), // Deep clinical teal
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF005B60).withValues(alpha: 0.25),
                        blurRadius: 6.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(displayName),
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s16),

          // 2. Greeting Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                salutation,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  fontSize: 22.0,
                  letterSpacing: -0.3,
                  height: 1.15,
                ),
              ),
              Text(
                firstName,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00807D), // Signature Teal
                  fontSize: 28.0,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Keep learning. Keep growing.',
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 3.0),
              const CustomPaint(
                size: Size(60.0, 4.0),
                painter: _BrushUnderlinePainter(),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}

class _BrushUnderlinePainter extends CustomPainter {
  const _BrushUnderlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00807D)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.1,
      size.width,
      size.height * 0.6,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeaderBackgroundPainter extends CustomPainter {
  final bool isArabic;

  const _HeaderBackgroundPainter({required this.isArabic});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Base soft gradient background
    final baseRect = Rect.fromLTWH(0, 0, w, h);
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEBF4FD), // Soft airy sky blue
          Color(0xFFF3F8FD),
          Color(0xFFFBFDFF),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(baseRect);
    canvas.drawRect(baseRect, basePaint);

    // 2. Organic Mint/Teal Blob Shape on the side where the graduation cap sits
    final blobPath = Path();
    if (!isArabic) {
      // English: Top-right organic swell
      blobPath.moveTo(w * 0.35, 0);
      blobPath.cubicTo(
        w * 0.45, h * 0.25,
        w * 0.52, h * 0.65,
        w * 0.76, h * 0.88,
      );
      blobPath.cubicTo(
        w * 0.88, h * 0.98,
        w * 0.96, h * 0.95,
        w, h * 0.85,
      );
      blobPath.lineTo(w, 0);
      blobPath.close();

      final blobPaint = Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.65, -0.4),
          radius: 1.0,
          colors: [
            Color(0xFFC7F0E6), // Soft mint teal
            Color(0xFFD6F5ED),
            Color(0xFFE8FAF5),
            Color(0x00E8FAF5),
          ],
          stops: [0.0, 0.45, 0.80, 1.0],
        ).createShader(Rect.fromLTWH(w * 0.3, 0, w * 0.7, h));
      canvas.drawPath(blobPath, blobPaint);
    } else {
      // Arabic: Top-left organic swell
      blobPath.moveTo(w * 0.65, 0);
      blobPath.cubicTo(
        w * 0.55, h * 0.25,
        w * 0.48, h * 0.65,
        w * 0.24, h * 0.88,
      );
      blobPath.cubicTo(
        w * 0.12, h * 0.98,
        w * 0.04, h * 0.95,
        0, h * 0.85,
      );
      blobPath.lineTo(0, 0);
      blobPath.close();

      final blobPaint = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.65, -0.4),
          radius: 1.0,
          colors: [
            Color(0xFFC7F0E6),
            Color(0xFFD6F5ED),
            Color(0xFFE8FAF5),
            Color(0x00E8FAF5),
          ],
          stops: [0.0, 0.45, 0.80, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w * 0.7, h));
      canvas.drawPath(blobPath, blobPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeaderBackgroundPainter oldDelegate) =>
      oldDelegate.isArabic != isArabic;
}
