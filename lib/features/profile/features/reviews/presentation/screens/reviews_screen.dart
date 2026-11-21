// PATCH-24
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/sub_page.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final h = MediaQuery.of(context).size.height;
    return SubPage(
      title: 'Reviews',
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 0),
            Row(
              children: [
                Text('Reviews', style: dmStyle(c.title, size: 17.4, h: 1.2, ls: -0.52)),
                const SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: p.countBg, shape: BoxShape.circle),
                  child: Text('0', style: interStyle(p.mutedText, size: 10.3, h: 1, ls: 0)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 48.3,
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
            SizedBox(height: (h * 0.0) + 150),
            Image.asset('packages/miam_assets/images/empty_states/error.png', width: 142, height: 142),
            const SizedBox(height: 28),
            Text(
              "We couldn't reach the server. Check your connection and try again.",
              textAlign: TextAlign.center,
              style: interStyle(p.mutedText, size: 16, h: 1.5, ls: -0.3),
            ),
          ],
        ),
      ),
    );
  }
}
