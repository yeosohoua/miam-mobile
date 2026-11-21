// PATCH-24
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_icons.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/app_toast.dart';
import '../../../../../../core/widgets/icon_tile.dart';
import '../../../../../../core/widgets/sub_page.dart';

class LoginSecuritySettingsScreen extends StatefulWidget {
  const LoginSecuritySettingsScreen({super.key});
  @override
  State<LoginSecuritySettingsScreen> createState() => _LoginSecuritySettingsScreenState();
}

class _LoginSecuritySettingsScreenState extends State<LoginSecuritySettingsScreen> {
  final _sessions = <(bool, String, String)>[
    (false, 'Android', 'Abidjan (Cocody), CI · 6 minutes ago'),
    (true, 'Web', 'Vaudoy-en-Brie, FR · 13 hours ago'),
    (false, 'Android', 'Naaldwijk, NL · 19 hours ago'),
    (true, 'Web', 'Tirana, AL · 3 days ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    Widget card(String title, String desc, List<Widget> rows) => Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20.5, 20, 12, 20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: p.line, width: 1.2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: dmStyle(c.title, size: 17.4, h: 1.2, ls: -0.52)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(desc, style: interStyle(p.mutedText, size: 14, h: 1.15, ls: -0.28)),
              ),
              const SizedBox(height: 14),
              ...rows,
            ],
          ),
        );
    return SubPage(
      title: 'Login & security',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
        child: Column(
          children: [
            card('Password', 'Change the password you use to sign in with email and password.', [
              Pressable(
                onTap: () => showAppToast(context, 'Update Password'),
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      const SizedBox(width: 0),
                      IconTile(icon: AppIcons.lock, iconSize: 20),
                      const SizedBox(width: 8.5),
                      Expanded(child: Text('Update Password', style: interStyle(c.title, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.28))),
                      Icon(AppIcons.chevronRight, size: 20, color: c.title),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            card('Active Sessions', 'Devices currently signed in to your account. Revoke any that you do not recognize.', [
              for (var i = 0; i < _sessions.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == _sessions.length - 1 ? 0 : 19.9),
                  child: Row(
                    children: [
                      IconTile(icon: _sessions[i].$1 ? Icons.language : Icons.smartphone_outlined, iconSize: 22),
                      const SizedBox(width: 8.5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_sessions[i].$2, style: interStyle(c.title, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.28)),
                            const SizedBox(height: 3),
                            Text(_sessions[i].$3, maxLines: 1, overflow: TextOverflow.ellipsis, style: interStyle(p.mutedText, size: 12.2, h: 1.2, ls: -0.2)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Pressable(
                        onTap: () => setState(() => _sessions.removeAt(i)),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(AppIcons.logout, size: 20, color: c.title),
                        ),
                      ),
                    ],
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}
