// PATCH-24
import 'package:flutter/material.dart';

import '../../../../../../core/app_settings.dart';
import '../../../../../../core/theme/app_icons.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/sub_page.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});
  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _Lang {
  const _Lang(this.code, this.name, this.native, this.flag);
  final String code, name, native, flag;
}

const _langs = [
  _Lang('en', 'English', 'English', 'us'),
  _Lang('fr', 'French', 'Français', 'fr'),
];

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _q = '';

  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    AppSettings.locale.addListener(_rebuild);
  }

  @override
  void dispose() {
    AppSettings.locale.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final cur = AppSettings.effectiveLang(context);
    final q = _q.trim().toLowerCase();
    final list = _langs.where((l) => q.isEmpty || l.name.toLowerCase().contains(q) || l.native.toLowerCase().contains(q) || l.code.contains(q)).toList();
    final ring = p.dark ? const Color(0xFFBDBDBD) : const Color(0xFFA8A8A8);
    return SubPage(
      title: 'Language Settings',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              height: 48.4,
              decoration: BoxDecoration(color: c.field, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  Icon(AppIcons.search, size: 24, color: c.title),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Material(
                      type: MaterialType.transparency,
                      child: TextField(
                        onChanged: (v) => setState(() => _q = v),
                        cursorColor: c.caret,
                        style: interStyle(c.title, size: 14, h: 1.2, ls: -0.3),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Search',
                          hintStyle: interStyle(p.mutedText, size: 14, h: 1.2, ls: -0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < list.length; i++)
              Pressable(
                onTap: () => AppSettings.setLocale(Locale(list[i].code)),
                child: Container(
                  height: 66,
                  decoration: BoxDecoration(border: i < list.length - 1 ? Border(bottom: BorderSide(color: p.divider, width: 0.8)) : null),
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset('packages/miam_assets/images/countries/${list[i].flag}.svg.png', width: 32, height: 32, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 8.2),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(list[i].name, style: interStyle(c.title, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.28)),
                            const SizedBox(height: 3),
                            Text(list[i].code, style: interStyle(p.mutedText, size: 12, h: 1.2, ls: -0.2)),
                          ],
                        ),
                      ),
                      _Radio(selected: list[i].code == cur, color: ring, onColor: c.background, fill: p.dark ? const Color(0xFFBDBDBD) : Colors.black),
                      const SizedBox(width: 6.8),
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

class _Radio extends StatelessWidget {
  const _Radio({required this.selected, required this.color, required this.onColor, required this.fill});
  final bool selected;
  final Color color, onColor, fill;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 20.2,
        height: 20.2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? fill : Colors.transparent,
          border: Border.all(color: selected ? fill : color, width: 1.4),
        ),
        child: selected ? Icon(AppIcons.checkThin, size: 15, color: onColor) : null,
      );
}
