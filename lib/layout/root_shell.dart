import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pass_kuai/provider/study_service_provider.dart';
import 'package:pass_kuai/theme/app_colors.dart';

class RootShell extends ConsumerWidget {
  const RootShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    _TabSpec(label: '분석', icon: Icons.search_rounded, selectedIcon: Icons.search_rounded),
    _TabSpec(label: '복습', icon: Icons.style_outlined, selectedIcon: Icons.style_rounded),
    _TabSpec(label: '단어장', icon: Icons.bookmarks_outlined, selectedIcon: Icons.bookmarks_rounded),
  ];

  void _onTap(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(dueCountProvider).valueOrNull ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Center(
            heightFactor: 1,
            child: _FloatingTabBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _onTap,
              tabs: _tabs,
              badges: {1: due},
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.label, required this.icon, required this.selectedIcon});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _FloatingTabBar extends StatelessWidget {
  const _FloatingTabBar({
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
    required this.badges,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_TabSpec> tabs;
  final Map<int, int> badges;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.line),
        boxShadow: floatingShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            _TabItem(
              spec: tabs[i],
              selected: i == currentIndex,
              badge: badges[i] ?? 0,
              onTap: () => onTap(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.spec,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.sub;
    final icon = Badge(
      isLabelVisible: badge > 0,
      label: Text(badge > 99 ? '99+' : '$badge'),
      backgroundColor: selected ? Colors.white : AppColors.primary,
      textColor: selected ? AppColors.primaryText : Colors.white,
      child: Icon(selected ? spec.selectedIcon : spec.icon, color: fg, size: 22),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: badge > 0 ? '${spec.label}, $badge개' : spec.label,
      excludeSemantics: true,
      child: Tooltip(
        message: spec.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            height: 48,
            constraints: const BoxConstraints(minWidth: 52),
            padding: EdgeInsets.only(left: selected ? 16 : 14, right: selected ? 20 : 14),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: selected ? primaryShadow : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            spec.label,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: AppWeights.label,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
