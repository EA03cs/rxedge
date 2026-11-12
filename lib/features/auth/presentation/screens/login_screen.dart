import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/error/failure_message_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

/// Corporate Login Screen for Medical Representatives
///
/// Follows Design & UX Specifications:
/// "3. Login: username + password only, show/hide toggle, inline field errors,
/// a primary 'Sign in' button with loading state, and a quiet note 'Accounts are provided by your company'.
/// 'Forgot password?' opens a simple screen telling the MR to contact the marketing team.
/// Keep-me-signed-in via secure storage. Optional biometric unlock prompt after first login."
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _usernameError;
  String? _passwordError;
  String? _generalError;
  bool _keepSignedIn = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final l10n = context.l10n;
    setState(() {
      _usernameError = null;
      _passwordError = null;
      _generalError = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    bool hasValidation = false;
    if (username.isEmpty) {
      _usernameError = l10n.usernameRequired;
      hasValidation = true;
    }
    if (password.isEmpty) {
      _passwordError = l10n.passwordRequired;
      hasValidation = true;
    }

    if (hasValidation) {
      setState(() {});
      return;
    }

    final failure = await ref.read(authControllerProvider.notifier).login(
      username: username,
      password: password,
      keepSignedIn: _keepSignedIn,
    );

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        if (failure is ValidationFailure) {
          _usernameError = failure.fieldErrors['username'];
          _passwordError = failure.fieldErrors['password'];
        } else if (failure is UnauthorizedFailure) {
          _generalError = l10n.invalidCredentials;
        } else {
          _generalError = FailureMessageMapper.map(context, failure);
        }
      });
    }
  }

  void _showBiometricDialog(BuildContext context) {
    final colors = context.rxColors;
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
      backgroundColor: colors.surface,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            RxSpacing.s24,
            RxSpacing.s24,
            RxSpacing.s24,
            RxSpacing.s32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Icon(
                  LucideIcons.fingerprint,
                  size: 28.0,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: RxSpacing.s16),
              Text(
                l10n.biometricPromptTitle,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: RxSpacing.s8),
              Text(
                l10n.biometricPromptDesc,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: RxSpacing.s24),
              AppButton(
                text: l10n.enableBiometrics,
                variant: AppButtonVariant.primary,
                leadingIcon: LucideIcons.fingerprint,
                onPressed: () {
                  Navigator.pop(bottomSheetContext);
                  ref.read(authControllerProvider.notifier).setBiometrics(true);
                  context.go(AppRoutes.home);
                },
              ),
              const SizedBox(height: RxSpacing.s12),
              AppButton(
                text: l10n.maybeLater,
                variant: AppButtonVariant.ghost,
                onPressed: () {
                  Navigator.pop(bottomSheetContext);
                  ref.read(authControllerProvider.notifier).dismissBiometricPrompt();
                  context.go(AppRoutes.home);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthAuthenticating;

    // Listen for state change to authenticated
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted) return;
      if (next is AuthAuthenticated) {
        if (next.promptBiometrics) {
          _showBiometricDialog(context);
        } else {
          context.go(AppRoutes.home);
        }
      }
    });

    String? sessionExpiredNotice;
    if (authState is AuthUnauthenticated && authState.sessionMessage != null) {
      sessionExpiredNotice = authState.sessionMessage == 'session_expired'
          ? l10n.sessionExpiredNotice
          : authState.sessionMessage;
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Mark & Language Toggle Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 48.0,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.activity,
                            size: 24.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final activeLocale = ref.watch(localeProvider);
                          final isArabic = activeLocale.languageCode == 'ar';
                          return TextButton.icon(
                            icon: const Icon(LucideIcons.globe, size: 16),
                            label: Text(
                              isArabic ? 'English' : 'العربية',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              final newLocale = isArabic ? const Locale('en') : const Locale('ar');
                              ref.read(localeProvider.notifier).state = newLocale;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s24),
                  Text(
                    l10n.loginTitle,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s6),
                  Text(
                    l10n.loginSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s24),

                  // Session Expiry Notice
                  if (sessionExpiredNotice != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                      decoration: BoxDecoration(
                        color: colors.warningSoft,
                        borderRadius: RxRadii.borderCard,
                        border: Border.all(
                          color: colors.warning.withValues(alpha: 0.3),
                          width: RxShadows.hairlineBorderWidth,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.alertTriangle, size: 18.0, color: colors.warning),
                          const SizedBox(width: RxSpacing.s10),
                          Expanded(
                            child: Text(
                              sessionExpiredNotice,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s16),
                  ],

                  // General Error Notice (Wrong credentials / Offline)
                  if (_generalError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                      decoration: BoxDecoration(
                        color: colors.errorSoft,
                        borderRadius: RxRadii.borderCard,
                        border: Border.all(
                          color: colors.error.withValues(alpha: 0.3),
                          width: RxShadows.hairlineBorderWidth,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.alertCircle, size: 18.0, color: colors.error),
                          const SizedBox(width: RxSpacing.s10),
                          Expanded(
                            child: Text(
                              _generalError!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s16),
                  ],

                  // Username / Email input
                  AppTextField(
                    label: l10n.usernameLabel,
                    hint: l10n.usernameHint,
                    controller: _usernameController,
                    errorText: _usernameError,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(LucideIcons.user, size: 18.0, color: colors.textSecondary),
                  ),
                  const SizedBox(height: RxSpacing.s16),

                  // Password input with show/hide toggle
                  AppTextField(
                    label: l10n.passwordLabel,
                    hint: l10n.passwordHint,
                    controller: _passwordController,
                    obscureText: true,
                    errorText: _passwordError,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submitLogin(),
                    prefixIcon: Icon(LucideIcons.lock, size: 18.0, color: colors.textSecondary),
                  ),
                  const SizedBox(height: RxSpacing.s12),

                  // Keep me signed in + Forgot password row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: InkWell(
                          onTap: () => setState(() => _keepSignedIn = !_keepSignedIn),
                          borderRadius: BorderRadius.circular(4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: Checkbox(
                                  value: _keepSignedIn,
                                  activeColor: colors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                  side: BorderSide(color: colors.border, width: 1.5),
                                  onChanged: (val) => setState(() => _keepSignedIn = val ?? true),
                                ),
                              ),
                              const SizedBox(width: RxSpacing.s8),
                              Flexible(
                                child: Text(
                                  l10n.keepMeSignedIn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: RxSpacing.s8),
                        ),
                        child: Text(
                          l10n.forgotPassword,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s24),

                  // Sign in Button
                  AppButton(
                    text: l10n.signIn,
                    variant: AppButtonVariant.primary,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submitLogin,
                  ),
                  const SizedBox(height: RxSpacing.s16),

                  // Quiet Note
                  Center(
                    child: Text(
                      l10n.companyAccountNote,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textTertiary,
                        fontSize: 12.0,
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
