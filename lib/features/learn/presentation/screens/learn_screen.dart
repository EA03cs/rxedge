import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/learning_entities.dart';
import '../controllers/learn_controller.dart';
import '../widgets/learn_skeleton_loader.dart';
import 'bookmarks_screen.dart';
import 'product_learning_screen.dart';

/// Smart Learning Hub (Learn Tab)
///
/// Executive Healthcare Redesign:
/// 1. Top Clinical Header Banner:
///    - Luminous gradient background with ambient medical cross bokeh
///    - 3D Open Medical Textbook & glowing caduceus chalice illustration
///    - Live Search Bar allowing real-time product & therapeutic area filtering
/// 2. Redesigned Horizontal Product Cards:
///    - Custom bottom-corner organic waves tailored to each therapeutic area
///    - 16:9 rounded visual thumbnail with "★ Recommended" sapphire overlay
///    - "✔ Completed" / "● In Progress" status badges
///    - Micro-meta with blue play circle & lesson completion counts
///    - ProgressRing with bold percentage & forward chevron
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    const options = ['All', 'In Progress', 'Completed', 'Not Started'];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Progress',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (_statusFilter != 'All')
                    TextButton(
                      onPressed: () {
                        setState(() => _statusFilter = 'All');
                        Navigator.of(sheetCtx).pop();
                      },
                      child: const Text('Reset'),
                    ),
                ],
              ),
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: options.map((opt) {
                  final selected = _statusFilter == opt;
                  return ChoiceChip(
                    label: Text(opt),
                    selected: selected,
                    selectedColor: colors.primarySoft,
                    labelStyle: TextStyle(
                      color: selected ? colors.primary : colors.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() => _statusFilter = opt);
                      Navigator.of(sheetCtx).pop();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    final learnAsync = ref.watch(learnControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2FE), // Soft ice cyan
              Color(0xFFEBF6FD),
              Color(0xFFF1F7FD),
              Color(0xFFF8FAFC),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.16, 0.32, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: learnAsync.when(
            loading: () => const Padding(
              padding: EdgeInsetsDirectional.only(top: 16.0),
              child: LearnSkeletonLoader(),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
                child: ErrorState(
                  title: l10n.errorStateTitle,
                  description: err.toString().replaceAll('Exception: ', ''),
                  retryText: l10n.errorStateRetry,
                  onRetry: () => ref.read(learnControllerProvider.notifier).refresh(),
                ),
              ),
            ),
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: EmptyState(
                    icon: LucideIcons.graduationCap,
                    title: l10n.noLearningModulesTitle,
                    description: l10n.noLearningModulesDesc,
                    actionText: l10n.retry,
                    onAction: () => ref.read(learnControllerProvider.notifier).refresh(),
                  ),
                );
              }

              final query = _searchQuery.trim().toLowerCase();
              final filteredProducts = products.where((p) {
                final matchesQuery = query.isEmpty ||
                    p.name.toLowerCase().contains(query) ||
                    p.therapeuticArea.toLowerCase().contains(query);
                if (!matchesQuery) return false;
                switch (_statusFilter) {
                  case 'Completed':
                    return p.isCompleted;
                  case 'In Progress':
                    return p.isInProgress;
                  case 'Not Started':
                    return p.completedLessonsCount == 0;
                  default:
                    return true;
                }
              }).toList();

              return RefreshIndicator(
                color: const Color(0xFF005CA8),
                backgroundColor: Colors.white,
                onRefresh: () => ref.read(learnControllerProvider.notifier).refresh(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Bar: Bookmarks Pill Button
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _BookmarksPillButton(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push<void>(
                                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // 2. Hero Header: Title + Subtitle + 3D Illustration
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 4.0, 20.0, 14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.learnTitle,
                                  style: const TextStyle(
                                    fontSize: 27.0,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                const Text(
                                  'Explore our product learning journey and grow your expertise.',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Color(0xFF64748B),
                                    height: 1.35,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Image.asset(
                            'assets/images/learn_header_illustration.png',
                            width: 96.0,
                            height: 96.0,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    // 3. Search Bar
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 8.0, 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: _isSearchFocused
                                ? const Color(0xFF005A9C)
                                : const Color(0xFFE2E8F0),
                            width: _isSearchFocused ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isSearchFocused
                                  ? const Color(0xFF005A9C).withValues(alpha: 0.12)
                                  : const Color(0xFF00386E).withValues(alpha: 0.05),
                              blurRadius: _isSearchFocused ? 14.0 : 10.0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.search,
                              size: 19.0,
                              color: _isSearchFocused
                                  ? const Color(0xFF005A9C)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                textAlignVertical: TextAlignVertical.center,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: 'Search products, monographs, trials...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Icon(
                                    LucideIcons.x,
                                    size: 18.0,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: () => _showFilterSheet(context),
                              child: Container(
                                width: 36.0,
                                height: 36.0,
                                decoration: BoxDecoration(
                                  color: (_isSearchFocused ||
                                          _statusFilter != 'All')
                                      ? const Color(0xFF005A9C)
                                      : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (_isSearchFocused ||
                                            _statusFilter != 'All')
                                        ? const Color(0xFF005A9C)
                                        : const Color(0xFFE2E8F0),
                                    width: 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  LucideIcons.slidersHorizontal,
                                  size: 16.0,
                                  color: (_isSearchFocused ||
                                          _statusFilter != 'All')
                                      ? Colors.white
                                      : const Color(0xFF005A9C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // 4. Products List
                    Expanded(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0,
                          0.0,
                          16.0,
                          24.0,
                        ),
                        children: [
                          // Section Subtitle & Count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Detailing Modules (${filteredProducts.length})',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              if (_statusFilter != 'All')
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _statusFilter = 'All'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F0FA),
                                      borderRadius: BorderRadius.circular(999.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _statusFilter,
                                          style: const TextStyle(
                                            color: Color(0xFF005CA8),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 4.0),
                                        const Icon(
                                          LucideIcons.x,
                                          size: 12.0,
                                          color: Color(0xFF005CA8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10.0),

                          if (filteredProducts.isEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(
                                      LucideIcons.searchX,
                                      size: 40.0,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(height: 12.0),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'No products match "$_searchQuery"'
                                          : 'No products in "$_statusFilter"',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    TextButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                          _statusFilter = 'All';
                                        });
                                      },
                                      child: Text(
                                        _searchQuery.isNotEmpty
                                            ? 'Clear search'
                                            : 'Reset filter',
                                        style: const TextStyle(
                                          color: Color(0xFF005CA8),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            ...filteredProducts.map(
                              (product) => _ProductCard(product: product),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BookmarksPillButton extends ConsumerWidget {
  final VoidCallback onTap;

  const _BookmarksPillButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final bookmarks = ref.watch(bookmarkedLessonsProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.0),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: RxSpacing.s12,
          vertical: RxSpacing.s6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999.0),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.bookmark, size: 13.0, color: colors.textSecondary),
            const SizedBox(width: RxSpacing.s6),
            Text(
              l10n.bookmarksLabel,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            if (bookmarks.isNotEmpty) ...[
              const SizedBox(width: RxSpacing.s6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(999.0),
                ),
                child: Text(
                  '${bookmarks.length}',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Redesigned Product Card matching the user's reference mockup
class _ProductCard extends StatelessWidget {
  final ProductLearningEntity product;

  const _ProductCard({required this.product});

  Color _getCategoryWaveColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dry aid') || lower.contains('dry-aid')) {
      return const Color(0xFF005CA8); // Mentholatum Cobalt for Dry Aid
    }
    if (lower.contains('cool')) {
      return const Color(0xFF0EA5E9); // Crisp Icy Blue for Rohto Cool
    }
    if (lower.contains('aqua')) {
      return const Color(0xFF10B981); // Gentle Emerald for Rohto Aqua
    }
    return const Color(0xFF38BDF8);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final waveColor = _getCategoryWaveColor(product.name);
    final percentage = (product.progress * 100).toInt();

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: CustomPaint(
            painter: _CardWavePainter(waveColor: waveColor, isRtl: false),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.0),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push<void>(
                    MaterialPageRoute(
                      builder: (_) => ProductLearningScreen(product: product),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Clean 16:9 Thumbnail Image (No overlapping badges)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.0),
                        child: RxNetworkImage(
                          imageUrl: product.boxImageUrl,
                          fallbackAsset: product.defaultAssetBanner,
                          width: 80.0,
                          height: 62.0,
                          borderRadius: BorderRadius.circular(14.0),
                          fit: BoxFit.cover,
                          fallbackIcon: LucideIcons.pill,
                        ),
                      ),
                      const SizedBox(width: RxSpacing.s12),

                      // 2. Middle Content Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Badges (Recommended / Completed / In Progress)
                            if (product.isRecommended || product.isCompleted || product.isInProgress) ...[
                              Wrap(
                                spacing: 6.0,
                                runSpacing: 4.0,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (product.isRecommended)
                                    Container(
                                      padding: const EdgeInsetsDirectional.symmetric(
                                        horizontal: 8.0,
                                        vertical: 2.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(999.0),
                                        border: Border.all(
                                          color: const Color(0xFFFCD34D),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 11.0,
                                            color: Color(0xFFD97706),
                                          ),
                                          const SizedBox(width: 3.5),
                                          Text(
                                            l10n.recommendedTag,
                                            style: const TextStyle(
                                              color: Color(0xFFB45309),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (product.isCompleted)
                                    Container(
                                      padding: const EdgeInsetsDirectional.symmetric(
                                        horizontal: 8.0,
                                        vertical: 2.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(999.0),
                                        border: Border.all(
                                          color: const Color(0xFF86EFAC),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 10.0,
                                            color: Color(0xFF166534),
                                          ),
                                          const SizedBox(width: 3.5),
                                          Text(
                                            l10n.completedBadge,
                                            style: const TextStyle(
                                              color: Color(0xFF166534),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (product.isInProgress)
                                    Container(
                                      padding: const EdgeInsetsDirectional.symmetric(
                                        horizontal: 7.0,
                                        vertical: 2.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(999.0),
                                        border: Border.all(
                                          color: const Color(0xFFBAE6FD),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 4.5,
                                            height: 4.5,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF005CA8),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            l10n.inProgressTag,
                                            style: const TextStyle(
                                              color: Color(0xFF0369A1),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3.0),
                            ],

                            // Product Name
                            Text(
                              product.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                fontSize: 15.0,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2.0),

                            // Therapeutic Area
                            Text(
                              product.therapeuticArea,
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5.0),

                            // Play Pill + Lessons Completed Count
                            Row(
                              children: [
                                Container(
                                  width: 17.0,
                                  height: 17.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEFF6FF),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    LucideIcons.play,
                                    size: 8.5,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                Flexible(
                                  child: Text(
                                    product.totalLessonsCount > 0
                                        ? l10n.lessonsCompleted(
                                            product.completedLessonsCount,
                                            product.totalLessonsCount,
                                          )
                                        : 'Modules in prep',
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.0,
                                      color: const Color(0xFF334155),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: RxSpacing.s10),

                      // 3. Circular Progress Ring & Chevron
                      ProgressRing(
                        value: product.progress,
                        size: 46.0,
                        strokeWidth: 4.0,
                        trackColor: const Color(0xFFF1F5F9),
                        color: product.progress == 0.0
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF059669), // Rich emerald green
                        center: Text(
                          '$percentage%',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.0,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 16.0,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Subtle Organic Wave Curve in Bottom-Right Corner of Product Card
class _CardWavePainter extends CustomPainter {
  final Color waveColor;
  final bool isRtl;

  const _CardWavePainter({required this.waveColor, this.isRtl = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint1 = Paint()
      ..color = waveColor.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    if (!isRtl) {
      path1.moveTo(w * 0.72, h);
      path1.cubicTo(
        w * 0.80, h * 0.76,
        w * 0.88, h * 0.52,
        w, h * 0.45,
      );
      path1.lineTo(w, h);
      path1.close();
    } else {
      path1.moveTo(w * 0.28, h);
      path1.cubicTo(
        w * 0.20, h * 0.76,
        w * 0.12, h * 0.52,
        0, h * 0.45,
      );
      path1.lineTo(0, h);
      path1.close();
    }
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = waveColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    if (!isRtl) {
      path2.moveTo(w * 0.60, h);
      path2.cubicTo(
        w * 0.72, h * 0.68,
        w * 0.84, h * 0.38,
        w, h * 0.30,
      );
      path2.lineTo(w, h);
      path2.close();
    } else {
      path2.moveTo(w * 0.40, h);
      path2.cubicTo(
        w * 0.28, h * 0.68,
        w * 0.16, h * 0.38,
        0, h * 0.30,
      );
      path2.lineTo(0, h);
      path2.close();
    }
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _CardWavePainter oldDelegate) =>
      oldDelegate.waveColor != waveColor || oldDelegate.isRtl != isRtl;
}
