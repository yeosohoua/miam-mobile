// PATCH-24
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_icons.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/icon_tile.dart';
import '../../../../../../core/widgets/sub_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final items = <(IconData, String, String)>[
      (AppIcons.globe, 'Language Settings', '/language-settings'),
      (AppIcons.palette, 'Appearance', '/appearance-settings'),
      (AppIcons.key, 'Login & security', '/login-security-settings'),
    ];
    return SubPage(
      title: 'Settings',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++)
              Pressable(
                onTap: () => Navigator.of(context).pushNamed(items[i].$3),
                child: SizedBox(
                  height: i == 0 ? 72 : 76,
                  child: Column(
                    children: [
                      SizedBox(height: i == 0 ? 13 : 17),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.3),
                        child: Row(
                          children: [
                            IconTile(icon: items[i].$1, iconSize: 20),
                            const SizedBox(width: 8.5),
                            Expanded(child: Text(items[i].$2, style: interStyle(p.c.title, size: 14.2, h: 1.2, ls: -0.28))),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (i < items.length - 1) Container(height: 1.1, color: p.divider),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
