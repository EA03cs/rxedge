import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';

/// Primary Product Selector for Marketing Hub
///
/// Implements client requirement:
/// "1. Make product selection the first, obvious control on the screen
/// (a segmented selector or product cards: Rohto Dry Aid / Rohto Cool & Aqua)"
class LibraryProductSelector extends StatelessWidget {
  final String? selectedProduct;
  final List<String> availableProducts;
  final ValueChanged<String?> onProductSelected;
  final bool? hasAquaMaterials;

  const LibraryProductSelector({
    super.key,
    required this.selectedProduct,
    required this.availableProducts,
    required this.onProductSelected,
    this.hasAquaMaterials,
  });

  bool get _hasAquaMaterials {
    if (hasAquaMaterials != null) return hasAquaMaterials!;
    return availableProducts.any((p) {
      final lower = p.toLowerCase();
      return lower.contains('aqua');
    });
  }

  bool get _hasRohtoProducts {
    return availableProducts.any((p) {
      final lower = p.toLowerCase();
      return lower.contains('rohto') ||
          lower.contains('dry aid') ||
          lower.contains('cool') ||
          lower.contains('aqua');
    });
  }

  bool _isCoolAquaSelected(String? current) {
    if (current == null) return false;
    final lower = current.toLowerCase();
    return lower.contains('cool') || lower.contains('aqua');
  }

  bool _isDryAidSelected(String? current) {
    if (current == null) return false;
    final lower = current.toLowerCase();
    return lower.contains('dry aid') || lower == 'rohto dry aid';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // If portfolio has Rohto products, render standard Rohto Dual-Segment selector
    if (_hasRohtoProducts || availableProducts.isEmpty) {
      final isDryAid = _isDryAidSelected(selectedProduct) || selectedProduct == null;
      final isCoolAqua = _isCoolAquaSelected(selectedProduct);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Primary Segmented Selector: Rohto Dry Aid vs Rohto Cool & Aqua
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Slate 100
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Option 1: Rohto Dry Aid
                Expanded(
                  child: _ProductSegmentButton(
                    title: l10n.productRohtoDryAid,
                    icon: LucideIcons.droplets,
                    isSelected: isDryAid && !isCoolAqua,
                    onTap: () => onProductSelected('Rohto Dry Aid'),
                  ),
                ),
                const SizedBox(width: 4.0),
                // Option 2: Rohto Cool & Aqua
                Expanded(
                  child: _ProductSegmentButton(
                    title: l10n.productRohtoCoolAqua,
                    icon: LucideIcons.sparkles,
                    isSelected: isCoolAqua,
                    onTap: () => onProductSelected('Rohto Cool & Aqua'),
                  ),
                ),
              ],
            ),
          ),

          // 2. Sub-Product Pills: when Rohto Cool & Aqua is active
          if (isCoolAqua) ...[
            const SizedBox(height: 8.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SubProductChip(
                    label: l10n.filterAll,
                    isSelected: selectedProduct == 'Rohto Cool & Aqua' ||
                        selectedProduct == 'Rohto Cool / Rohto Aqua',
                    onTap: () => onProductSelected('Rohto Cool & Aqua'),
                  ),
                  const SizedBox(width: 6.0),
                  _SubProductChip(
                    label: l10n.productRohtoCool,
                    isSelected: selectedProduct == 'Rohto Cool',
                    onTap: () => onProductSelected('Rohto Cool'),
                  ),
                  const SizedBox(width: 6.0),
                  _SubProductChip(
                    label: l10n.productRohtoAqua,
                    isSelected: selectedProduct == 'Rohto Aqua',
                    badge: _hasAquaMaterials ? null : l10n.statusComingSoon,
                    onTap: () => onProductSelected('Rohto Aqua'),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // Fallback for non-Rohto products (e.g. general test fixtures)
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SubProductChip(
              label: l10n.filterAllProducts,
              isSelected: selectedProduct == null,
              onTap: () => onProductSelected(null),
            ),
            ...availableProducts.map((p) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 6.0),
                child: _SubProductChip(
                  label: p,
                  isSelected: selectedProduct == p,
                  onTap: () => onProductSelected(p),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ProductSegmentButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductSegmentButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(9.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9.0),
            border: isSelected
                ? Border.all(color: const Color(0xFFCBD5E1), width: 1.0)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4.0,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.0,
                color: isSelected
                    ? const Color(0xFF005CA8)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6.0),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubProductChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _SubProductChip({
    required this.label,
    required this.isSelected,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF005CA8) : Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF005CA8)
                  : const Color(0xFFCBD5E1),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
