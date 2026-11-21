// PATCH-24
import 'package:flutter/material.dart';

import '../../../../../../core/demo/vendor_logos.dart';
import '../../../../../../core/theme/app_icons.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/sub_page.dart';

class _Order {
  const _Order(this.name, this.logo, this.completed, this.address, this.price, this.ago);
  final String name;
  final dynamic logo; // Uint8List? (null = initiale)
  final bool completed;
  final String address, price, ago;
}

final _orders = <_Order>[
  _Order('Fjell Coffee', VendorLogos.fjell, false, '5598 Avenue Martin Luther King Jr', r'$38.00', '3 days ago'),
  _Order('Marrow Kitchen', null, false, '42 Pushkin Street', r'$161.82', '6 days ago'),
  _Order('The Laurel Room', VendorLogos.laurel, true, 'Unnamed Road', r'$128.97', '27 days ago'),
  _Order('Komugi Bakery', null, false, 'Unnamed Road', r'$79.48', '27 days ago'),
  _Order('Fjell Coffee', VendorLogos.fjell, false, '5598 Avenue Martin Luther King Jr', r'$54.20', '28 days ago'),
  _Order('The Laurel Room', VendorLogos.laurel, true, 'Unnamed Road', r'$96.10', '30 days ago'),
];

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final navH = 78.8 + mq.padding.bottom;
    return SubPage(
      title: 'Order history',
      scrollable: false,
      child: Column(
        children: [
          const SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48.4,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: p.line, width: 1.2)),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(AppIcons.search, size: 24, color: c.title),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Material(
                      type: MaterialType.transparency,
                      child: TextField(
                        cursorColor: c.caret,
                        style: interStyle(c.title, size: 14, h: 1.2, ls: -0.3),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Shop, item, address or order number',
                          hintStyle: interStyle(p.mutedText, size: 14, h: 1.2, ls: -0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 17),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Orders', style: dmStyle(c.title, size: 17.4, h: 1.2, ls: -0.52)),
                const SizedBox(width: 10),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: p.countBg, shape: BoxShape.circle),
                  child: Text('${_orders.length}', style: interStyle(p.mutedText, size: 12.2, h: 1, ls: 0)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 0, 16, navH + 24),
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16.1),
              itemBuilder: (_, i) => _OrderCard(o: _orders[i], p: p),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.o, required this.p});
  final _Order o;
  final AppPalette p;

  @override
  Widget build(BuildContext context) {
    final c = p.c;
    final bg = o.completed
        ? (p.dark ? const Color(0xFF051F0F) : const Color(0xFFEEFAF2))
        : (p.dark ? const Color(0xFF210806) : const Color(0xFFFCEFEE));
    final fg = o.completed
        ? (p.dark ? const Color(0xFFA7E8BF) : const Color(0xFF147638))
        : (p.dark ? const Color(0xFFEA8D85) : const Color(0xFF8B2018));
    return Container(
      height: 153.9,
      padding: const EdgeInsets.symmetric(horizontal: 16.5),
      decoration: BoxDecoration(
        color: p.dark ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line, width: 1.2),
        boxShadow: p.dark ? null : const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: o.logo != null
                      ? Image.memory(o.logo, fit: BoxFit.cover, gaplessPlayback: true)
                      : ColoredBox(
                          color: p.tile,
                          child: Center(child: Text(o.name[0], style: dmStyle(c.title, size: 18, w: FontWeight.w600, h: 1))),
                        ),
                ),
              ),
              const SizedBox(width: 12.5),
              Expanded(child: Text(o.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: dmStyle(c.title, size: 14.8, w: FontWeight.w600, h: 1.2, ls: -0.52))),
              Container(
                height: 24,
                padding: const EdgeInsets.only(left: 8, right: 12),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                      child: Icon(o.completed ? AppIcons.checkThin : AppIcons.xThin, size: 11, color: bg),
                    ),
                    const SizedBox(width: 4),
                    Text(o.completed ? 'Completed' : 'Canceled', style: interStyle(fg, size: 12, w: FontWeight.w500, h: 1.2, ls: -0.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Icon(AppIcons.pin, size: 22, color: p.coral),
              const SizedBox(width: 7),
              Text('Address:', style: interStyle(p.mutedText, size: 14, h: 1.2, ls: -0.28)),
              const SizedBox(width: 25),
              Expanded(child: Text(o.address, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: interStyle(c.title, size: 14, h: 1.2, ls: -0.28))),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Text(o.price, style: interStyle(c.title, size: 13.8, w: FontWeight.w500, h: 1.2, ls: -0.28)),
              const Spacer(),
              Text(o.ago, style: interStyle(p.mutedText, size: 12, h: 1.2, ls: -0.2)),
            ],
          ),
          const SizedBox(height: 17),
        ],
      ),
    );
  }
}
