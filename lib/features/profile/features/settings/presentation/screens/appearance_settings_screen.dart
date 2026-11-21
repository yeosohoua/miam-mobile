// PATCH-24
import 'package:flutter/material.dart';

import '../../../../../../core/app_settings.dart';
import '../../../../../../core/theme/app_icons.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/sub_page.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    return SubPage(
      title: 'Appearance',
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppSettings.themeMode,
        builder: (context, mode, _) {
          final system = mode == ThemeMode.system;
          final isDark = p.dark;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: dmStyle(c.title, size: 15.2, h: 1.2, ls: -0.3)),
                const SizedBox(height: 6),
                Text('Choose light, dark, or follow the system setting', style: interStyle(p.mutedText, size: 12, h: 1.3, ls: -0.24)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line, width: 1.2)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dark / Light / System default', style: interStyle(c.title, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.28)),
                            const SizedBox(height: 4),
                            Text('Use system default light/dark mode', style: interStyle(p.mutedText, size: 12, h: 1.2, ls: -0.24)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Switch(
                        on: system,
                        onChanged: (v) => AppSettings.setThemeMode(v ? ThemeMode.system : (isDark ? ThemeMode.dark : ThemeMode.light)),
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: system
                      ? const SizedBox(width: double.infinity)
                      : Column(
                          children: [
                            const SizedBox(height: 8),
                            _ModeCard(label: 'Light mode', icon: Icons.wb_sunny_rounded, iconColor: const Color(0xFFFFBC33), selected: mode == ThemeMode.light, onTap: () => AppSettings.setThemeMode(ThemeMode.light)),
                            const SizedBox(height: 11.7),
                            _ModeCard(label: 'Dark mode', icon: Icons.nightlight_round, iconColor: p.dark ? const Color(0xFFCFD8FF) : const Color(0xFF3D4A8A), selected: mode == ThemeMode.dark, onTap: () => AppSettings.setThemeMode(ThemeMode.dark)),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.on, required this.onChanged});
  final bool on;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final track = p.c.title;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 36.2,
        height: 20.3,
        padding: const EdgeInsets.all(2.6),
        decoration: BoxDecoration(
          color: on ? track : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: on ? track : (p.dark ? const Color(0xFFBDBDBD) : const Color(0xFFA8A8A8)), width: 1.3),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 12.5,
            height: 12.5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: on ? p.c.background : (p.dark ? const Color(0xFFBDBDBD) : const Color(0xFFA8A8A8))),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.label, required this.icon, required this.iconColor, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final ring = p.dark ? const Color(0xFFBDBDBD) : const Color(0xFFA8A8A8);
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 66.2,
        padding: const EdgeInsets.only(left: 8.9, right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? c.title : p.line, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(shape: BoxShape.circle, color: p.tile),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: interStyle(c.title, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.28))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? c.title : Colors.transparent,
                border: Border.all(color: selected ? c.title : ring, width: 1.4),
              ),
              child: selected ? Icon(AppIcons.checkThin, size: 14, color: c.background) : null,
            ),
          ],
        ),
      ),
    );
  }
}
