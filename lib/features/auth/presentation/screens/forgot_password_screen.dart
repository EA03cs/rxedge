import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Corporate Password Assistance Screen
///
/// Follows Design & UX Specifications:
/// "'Forgot password?' opens a simple screen telling the MR to contact the marketing team."
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, size: 20.0, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56.0,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Icon(
                      LucideIcons.shieldAlert,
                      size: 28.0,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s20),
                  Text(
                    l10n.forgotPasswordTitle,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s12),
                  Text(
                    l10n.forgotPasswordInstructions,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s24),

                  // Corporate Support Contact Card
                  AppCard(
                    variant: AppCardVariant.muted,
                    child: Row(
                      children: [
                        Icon(LucideIcons.mail, size: 20.0, color: colors.primary),
                        const SizedBox(width: RxSpacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Commercial IT & Marketing Helpdesk',
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: RxSpacing.s2),
                              Text(
                                l10n.supportEmail,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s24),

                  AppButton(
                    text: l10n.contactMarketing,
                    variant: AppButtonVariant.primary,
                    leadingIcon: LucideIcons.send,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Support request sent to ${l10n.supportEmail}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: RxSpacing.s12),
                  AppButton(
                    text: l10n.backToLogin,
                    variant: AppButtonVariant.ghost,
                    onPressed: () => context.pop(),
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
