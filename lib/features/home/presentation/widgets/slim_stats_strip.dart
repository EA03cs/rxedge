import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../challenges/presentation/screens/challenges_screen.dart';
import '../../domain/entities/home_dashboard_entity.dart';

/// Slim Stats Strip
///
/// Features matching executive clinical design:
/// - 3 modern white cards with 18dp radius and soft shadow
/// - Pastel icon badges (Streak: Pink/Red, Points: Amber, Quizzes: Purple)
/// - Bold typography: large primary count and sub-label
/// - Micro upward-trending vector wave charts at the bottom of each card
class SlimStatsStrip extends StatelessWidget {
  final RepStatsEntity stats;

  const SlimStatsStrip({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Row(
        children: [
          // 1. Streak Card
          Expanded(
            child: _buildStatCard(
              context,
              icon: LucideIcons.flame,
              badgeBg: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFE11D48),
              value: '${stats.streakDays}',
              label: 'Day Streak',
              waveLineColor: const Color(0xFFF43F5E),
              waveFillColor: const Color(0xFFFEE2E2),
              colors: colors,
              textTheme: textTheme,
              onTap: () {
                Navigator.of(context, rootNavigator: true).push<void>(
                  MaterialPageRoute(
                    builder: (_) => const ChallengesScreen(initialTabIndex: 0),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: RxSpacing.s10),

          // 2. Points Card
          Expanded(
            child: _buildStatCard(
              context,
              icon: LucideIcons.award,
              badgeBg: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              value: '${stats.challengeMarks}',
              label: l10n.statPointsLabel,
              waveLineColor: const Color(0xFFF59E0B),
              waveFillColor: const Color(0xFFFEF3C7),
              colors: colors,
              textTheme: textTheme,
              onTap: () {
                Navigator.of(context, rootNavigator: true).push<void>(
                  MaterialPageRoute(
                    builder: (_) => const ChallengesScreen(initialTabIndex: 0),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: RxSpacing.s10),

          // 3. Quizzes Card
          Expanded(
            child: _buildStatCard(
              context,
              icon: LucideIcons.shieldCheck,
              badgeBg: const Color(0xFFEDE9FE),
              iconColor: const Color(0xFF7C3AED),
              value: '${stats.quizzesCompleted}',
              label: 'Quizzes',
              waveLineColor: const Color(0xFF8B5CF6),
              waveFillColor: const Color(0xFFEDE9FE),
              colors: colors,
              textTheme: textTheme,
              onTap: () {
                Navigator.of(context, rootNavigator: true).push<void>(
                  MaterialPageRoute(
                    builder: (_) => const ChallengesScreen(initialTabIndex: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color badgeBg,
    required Color iconColor,
    required String value,
    required String label,
    required Color waveLineColor,
    required Color waveFillColor,
    required RxColors colors,
    required TextTheme textTheme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          height: 84.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Bottom micro-wave chart
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 28.0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(17.0),
                    bottomRight: Radius.circular(17.0),
                  ),
                  child: CustomPaint(
                    painter: _StatWavePainter(
                      lineColor: waveLineColor,
                      fillColor: waveFillColor,
                    ),
                  ),
                ),
              ),

              // Content row (Badge + Value + Label)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 8.0, 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Circular icon badge
                    Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 16.0,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 8.0),

                    // Value and Label Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              value,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                fontSize: 17.0,
                                height: 1.15,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              label,
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatWavePainter extends CustomPainter {
  final Color lineColor;
  final Color fillColor;

  const _StatWavePainter({
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h * 0.85);
    path.cubicTo(w * 0.35, h * 0.9, w * 0.65, h * 0.45, w * 0.9, h * 0.25);

    final fillPath = Path.from(path);
    fillPath.lineTo(w * 0.9, h);
    fillPath.lineTo(0, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fillColor.withValues(alpha: 0.5),
          fillColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // End trending dot
    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(Offset(w * 0.9, h * 0.25), 2.5, dotPaint);

    // Outer faint halo for dot
    final haloPaint = Paint()..color = lineColor.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(w * 0.9, h * 0.25), 4.5, haloPaint);
  }

  @override
  bool shouldRepaint(covariant _StatWavePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.fillColor != fillColor;
}
