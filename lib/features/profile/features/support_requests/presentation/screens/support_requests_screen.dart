// PATCH-26
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/sub_page.dart';

class SupportRequestsScreen extends StatelessWidget {
  const SupportRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    return SubPage(
      title: 'Support',
      scrollable: false,
      child: Stack(
        children: [
          Positioned(
            top: 15.65,
            left: 16,
            right: 16,
            height: 48.4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.8),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: p.line, width: 1.2)),
              child: Material(
                type: MaterialType.transparency,
                child: TextField(
                  cursorColor: c.caret,
                  style: interStyle(c.title, size: 14, h: 1.2, ls: -0.3),
                  decoration: InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: 'Search', hintStyle: interStyle(p.mutedText, size: 14, h: 1.2, ls: -0.3)),
                ),
              ),
            ),
          ),
          Positioned(
            top: 83.6,
            left: 16,
            right: 16,
            child: Text.rich(
              TextSpan(
                text: 'Support Requests',
                style: dmStyle(c.title, size: 17.4, h: 1, ls: -0.52),
                children: [
                  TextSpan(text: ' (0)', style: dmStyle(p.mutedText, size: 17.4, w: FontWeight.w400, h: 1, ls: -0.3)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 271.5,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: p.dark ? 0.46 : 1,
                child: Image.asset('packages/miam_assets/images/empty_states/noRecord.png', width: 148, height: 148),
              ),
            ),
          ),
          Positioned(
            top: 448.9,
            left: 0,
            right: 0,
            child: Text(
              "“ You haven't opened any support requests ”",
              textAlign: TextAlign.center,
              style: interStyle(p.mutedText, size: 16, h: 1, ls: -0.3),
            ),
          ),
        ],
      ),
    );
  }
}
