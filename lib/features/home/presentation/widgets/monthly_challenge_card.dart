import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../challenges/presentation/screens/challenges_screen.dart';
import '../../domain/entities/home_dashboard_entity.dart';

/// "This Month's Challenge" Card matching executive clinical design:
/// - 20dp radius white card with soft shadow
/// - Left: Dark teal curved container with 3D golden trophy illustration
/// - Right: Target title + "7 days left" red pill + challenge title + progress + rank + circular chevron action
class MonthlyChallengeCard extends StatelessWidget {
  final MonthlyChallengeEntity challenge;

  const MonthlyChallengeCard({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    if (challenge.id.isEmpty && challenge.title.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final percentage = (challenge.progress * 100).toInt();

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push<void>(
              MaterialPageRoute(
                builder: (_) => const ChallengesScreen(initialTabIndex: 0),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 12.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left: Inspiring Dark Teal 3D Trophy Block with Organic Curved Edge
                  ClipPath(
                    clipper: const CurvedTrophyClipper(isRtl: false),
                    child: Container(
                      width: 102.0,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF00444C), // Deep rich oceanic teal
                            Color(0xFF006773), // Vibrant jewel teal
                            Color(0xFF007A87), // Inspiring glowing teal highlight
                          ],
                        ),
                      ),
                      padding: const EdgeInsetsDirectional.only(
                        start: 6.0,
                        end: 14.0,
                        top: 6.0,
                        bottom: 6.0,
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft radial golden ambient glow behind the trophy
                          Container(
                            width: 82.0,
                            height: 82.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFFD54F).withValues(alpha: 0.38),
                                  const Color(0xFF00E5FF).withValues(alpha: 0.12),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),
                          // Big, commanding 3D Golden Trophy
                          Image.asset(
                            'assets/images/home_trophy_3d.png',
                            width: 82.0,
                            height: 96.0,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right: Challenge Info & Metrics
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top row: Target Icon + Title on left, Red Pill on right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LucideIcons.target,
                                      size: 14.0,
                                      color: Color(0xFF0D9488),
                                    ),
                                    const SizedBox(width: 4.0),
                                    Flexible(
                                      child: Text(
                                        "This Month's Challenge",
                                        style: textTheme.labelSmall?.copyWith(
                                          color: const Color(0xFF475569),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.0,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6.0),

                              // Red "7 days left" badge pill
                              Container(
                                padding: const EdgeInsetsDirectional.fromSTEB(7.0, 3.0, 8.0, 3.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LucideIcons.clock,
                                      size: 11.0,
                                      color: Color(0xFFEF4444),
                                    ),
                                    const SizedBox(width: 3.5),
                                    Text(
                                      l10n.daysLeft(challenge.daysLeft),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: const Color(0xFFEF4444),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),

                          // Challenge Title
                          Text(
                            challenge.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              fontSize: 14.5,
                              letterSpacing: -0.2,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8.0),

                          // Progress percentage & bar
                          Text(
                            '$percentage%',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: LinearProgressIndicator(
                              value: challenge.progress,
                              minHeight: 5.5,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          // Scope Rank & Action Chevron
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LucideIcons.trophy,
                                      size: 13.0,
                                      color: Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 5.0),
                                    Flexible(
                                      child: Builder(
                                        builder: (context) {
                                          final rawScope =
                                              challenge.scopeName.trim();
                                          final scope = rawScope.isNotEmpty
                                              ? rawScope
                                              : 'Company';
                                          final isArabic = l10n.localeName == 'ar';
                                          final arScope = scope == 'Company'
                                              ? 'الشركة'
                                              : scope;
                                          final rankLabel =
                                              challenge.currentRank > 0
                                                  ? (isArabic
                                                      ? 'الترتيب #${challenge.currentRank} من أصل ${challenge.totalParticipants} في $arScope'
                                                      : 'Rank #${challenge.currentRank} of ${challenge.totalParticipants} in $scope')
                                                  : (isArabic
                                                      ? 'غير مصنف في $arScope'
                                                      : 'Unranked in $scope');
                                          return Text(
                                            rankLabel,
                                            style: textTheme.bodySmall?.copyWith(
                                              color: const Color(0xFF475569),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6.0),

                              // Circular Light Blue Chevron Button
                              Container(
                                width: 28.0,
                                height: 28.0,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F2FE),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  context.chevronForward,
                                  size: 14.0,
                                  color: const Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom clipper creating the organic convex curve matching the executive UI design.
class CurvedTrophyClipper extends CustomClipper<Path> {
  final bool isRtl;

  const CurvedTrophyClipper({this.isRtl = false});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    if (!isRtl) {
      path.moveTo(0, 0);
      path.lineTo(w - 18.0, 0);
      path.cubicTo(
        w, h * 0.25,
        w - 1.0, h * 0.55,
        w - 26.0, h,
      );
      path.lineTo(0, h);
      path.close();
    } else {
      path.moveTo(w, 0);
      path.lineTo(18.0, 0);
      path.cubicTo(
        0.0, h * 0.25,
        1.0, h * 0.55,
        26.0, h,
      );
      path.lineTo(w, h);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CurvedTrophyClipper oldClipper) => oldClipper.isRtl != isRtl;
}
