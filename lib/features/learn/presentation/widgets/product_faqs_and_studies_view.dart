import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/learning_entities.dart';

/// Product FAQs and Clinical Studies View (Tab 3 in Product Navigator)
class ProductFaqsAndStudiesView extends StatefulWidget {
  final ProductLearningEntity product;

  const ProductFaqsAndStudiesView({
    super.key,
    required this.product,
  });

  @override
  State<ProductFaqsAndStudiesView> createState() =>
      _ProductFaqsAndStudiesViewState();
}

class _ProductFaqsAndStudiesViewState extends State<ProductFaqsAndStudiesView> {
  String _searchQuery = '';
  final Set<String> _expandedFaqIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final faqs = widget.product.faqs;
    final studies = widget.product.supportingStudies;
    final packShots = widget.product.packShots;

    final filteredFaqs = faqs.where((faq) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return faq.question.toLowerCase().contains(q) ||
          faq.answer.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Pack Shots Gallery (if available)
          if (packShots.isNotEmpty) ...[
            _SectionHeader(
              icon: LucideIcons.image,
              title: l10n.packShotsTitle,
              color: colors.primary,
            ),
            const SizedBox(height: RxSpacing.s8),
            SizedBox(
              height: 120.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: packShots.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: RxSpacing.s10),
                itemBuilder: (context, index) {
                  final ps = packShots[index];
                  return Container(
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: RxRadii.borderCard,
                      border: Border.all(
                        color: colors.border,
                        width: RxShadows.hairlineBorderWidth,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      ps.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          LucideIcons.packageCheck,
                          size: 32.0,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: RxSpacing.s20),
          ],

          // 2. Supporting Clinical Studies (if available)
          if (studies.isNotEmpty) ...[
            _SectionHeader(
              icon: LucideIcons.fileSpreadsheet,
              title: l10n.supportingStudiesTitle,
              color: colors.info,
            ),
            const SizedBox(height: RxSpacing.s8),
            ...studies.map((study) => Container(
                  margin: const EdgeInsetsDirectional.only(bottom: RxSpacing.s8),
                  padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: RxRadii.borderCard,
                    border: Border.all(
                      color: colors.border,
                      width: RxShadows.hairlineBorderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsetsDirectional.all(RxSpacing.s8),
                        decoration: BoxDecoration(
                          color: colors.infoSoft,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          study.studyType == 'e_detailed_slides'
                              ? LucideIcons.presentation
                              : LucideIcons.fileText,
                          size: 18.0,
                          color: colors.info,
                        ),
                      ),
                      const SizedBox(width: RxSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              study.title,
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: RxSpacing.s2),
                            Text(
                              study.studyType == 'e_detailed_slides'
                                  ? 'E-Detailed Slides'
                                  : 'Clinical Study Paper',
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.externalLink, size: 18.0),
                        tooltip: l10n.openStudy,
                        onPressed: () => _openLink(study.fileUrl),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: RxSpacing.s20),
          ],

          // 3. Product FAQs Section
          _SectionHeader(
            icon: LucideIcons.helpCircle,
            title: l10n.faqsTitle,
            color: colors.primary,
          ),
          const SizedBox(height: RxSpacing.s8),

          if (faqs.length > 3) ...[
            AppTextField(
              hint: 'ابحث في الأسئلة الشائعة...',
              prefixIcon: const Icon(LucideIcons.search, size: 18.0),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: RxSpacing.s12),
          ],

          if (filteredFaqs.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: RxRadii.borderCard,
                border: Border.all(
                  color: colors.border,
                  width: RxShadows.hairlineBorderWidth,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.messageSquareDashed,
                    size: 32.0,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(height: RxSpacing.s8),
                  Text(
                    l10n.noFaqsAvailable,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            ...filteredFaqs.map((faq) {
              final isExpanded = _expandedFaqIds.contains(faq.id);
              return Container(
                margin: const EdgeInsetsDirectional.only(bottom: RxSpacing.s8),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: RxRadii.borderCard,
                  border: Border.all(
                    color: isExpanded ? colors.primary : colors.border,
                    width: isExpanded ? 1.2 : RxShadows.hairlineBorderWidth,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: RxRadii.borderCard,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedFaqIds.remove(faq.id);
                        } else {
                          _expandedFaqIds.add(faq.id);
                        }
                      });
                    },
                    borderRadius: RxRadii.borderCard,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(RxSpacing.s14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsetsDirectional.all(
                                    RxSpacing.s6),
                                decoration: BoxDecoration(
                                  color: colors.primarySoft,
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Icon(
                                  LucideIcons.helpCircle,
                                  size: 14.0,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(width: RxSpacing.s10),
                              Expanded(
                                child: Text(
                                  faq.question,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? LucideIcons.chevronUp
                                    : LucideIcons.chevronDown,
                                size: 18.0,
                                color: colors.textTertiary,
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: RxSpacing.s10),
                            Divider(
                              height: RxSpacing.s12,
                              thickness: RxShadows.hairlineBorderWidth,
                              color: colors.border,
                            ),
                            const SizedBox(height: RxSpacing.s6),
                            Text(
                              faq.answer,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.rxColors;

    return Row(
      children: [
        Icon(icon, size: 16.0, color: color),
        const SizedBox(width: RxSpacing.s8),
        Text(
          title,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
