import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/error/failure_message_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/app_info_entity.dart';
import '../controllers/app_info_controller.dart';

/// App Info Screen (Reference Architectural Implementation)
///
/// Follows Architectural Contract:
/// 1. "Widgets are dumb: no business logic, no API calls, no JSON parsing inside widgets."
/// 2. "Every async state is exposed as AsyncValue and rendered with shared loading/empty/error widgets."
/// 3. "No hardcoded strings, colors, spacing or text styles."
class AppInfoScreen extends ConsumerWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final appInfoAsync = ref.watch(appInfoControllerProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          l10n.systemDiagnosticsTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: l10n.appMetadataTitle,
              subtitle: l10n.appMetadataSubtitle,
            ),
            const SizedBox(height: RxSpacing.s8),
            appInfoAsync.when(
              loading: () => _buildLoadingSkeleton(context),
              error: (error, _) => _buildErrorState(context, ref, error),
              data: (info) => _buildContent(context, ref, info),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return const Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox.text(width: 160.0, height: 16.0),
              SizedBox(height: RxSpacing.s12),
              SkeletonBox(width: double.infinity, height: 80.0),
              SizedBox(height: RxSpacing.s16),
              SkeletonBox.text(width: 220.0, height: 12.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final l10n = context.l10n;
    String message;
    if (error is Failure) {
      message = FailureMessageMapper.map(context, error);
    } else {
      message = l10n.errorStateDescription;
    }

    return AppCard(
      child: ErrorState(
        title: l10n.unableLoadDiagnostics,
        description: message,
        retryText: l10n.retryConnection,
        onRetry: () => ref.read(appInfoControllerProvider.notifier).refresh(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AppInfoEntity info) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(RxSpacing.s8),
                        decoration: BoxDecoration(
                          color: colors.primarySoft,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          LucideIcons.cpu,
                          size: 20.0,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: RxSpacing.s12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.appName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            'v${info.version} (Build ${info.buildNumber})',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  StatusBadge(
                    label: info.environment.toUpperCase(),
                    variant: info.environment == 'production'
                        ? StatusBadgeVariant.success
                        : StatusBadgeVariant.warning,
                    showDot: true,
                  ),
                ],
              ),
              const SizedBox(height: RxSpacing.s16),
              Divider(color: colors.border, height: 1.0),
              const SizedBox(height: RxSpacing.s16),
              _buildMetaRow(context, l10n.minSupportedVersionLabel, info.minSupportedVersion),
              const SizedBox(height: RxSpacing.s8),
              _buildMetaRow(context, l10n.maintenanceStatusLabel, info.maintenanceMode ? l10n.maintenanceActive : l10n.operationalStatus),
              const SizedBox(height: RxSpacing.s8),
              _buildMetaRow(context, l10n.apiEndpointLabel, info.apiEndpoint.isNotEmpty ? info.apiEndpoint : l10n.configuredBaseUrl),
              const SizedBox(height: RxSpacing.s8),
              _buildMetaRow(context, l10n.serverTimeLabel, Formatters.formatDate(info.serverTimestamp, format: 'yyyy-MM-dd HH:mm:ss')),
            ],
          ),
        ),
        const SizedBox(height: RxSpacing.s20),
        AppButton(
          text: l10n.refreshSystemStatus,
          leadingIcon: LucideIcons.rotateCw,
          variant: AppButtonVariant.secondary,
          onPressed: () => ref.read(appInfoControllerProvider.notifier).refresh(),
        ),
      ],
    );
  }

  Widget _buildMetaRow(BuildContext context, String label, String value) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
