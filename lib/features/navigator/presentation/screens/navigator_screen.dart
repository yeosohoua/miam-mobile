// PATCH-24
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../profile/features/wallet/presentation/screens/wallet_screen.dart';
import '../../../profile/presentation/screens/profile_tab.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../navigator_scope.dart';

const _inter = 'packages/miam_assets/Inter';

/// Coque de navigation: 4 onglets + bouton panier central.
/// Slots: 0 Home, 1 Wallet, 2 Panier (bouton), 3 Orders, 4 Profile.
class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({super.key});

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  int _slot = 0;
  final Set<int> _built = {0};
  final _profileKey = GlobalKey<NavigatorState>();
  final _profileDepth = ValueNotifier<int>(0);

  Widget _page(int slot) {
    switch (slot) {
      case 0:
        return const HomeScreen();
      case 1:
        return const WalletScreen();
      case 3:
        return const OrdersScreen();
      default:
        return ProfileTab(navKey: _profileKey, depth: _profileDepth);
    }
  }

  void _select(int slot) {
    if (slot == _slot) return;
    HapticFeedback.selectionClick();
    setState(() {
      _slot = slot;
      _built.add(slot);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: _profileDepth,
      builder: (context, depth, child) => PopScope(
        canPop: !(_slot == 4 && depth > 0),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _profileKey.currentState?.maybePop();
        },
        child: child!,
      ),
      child: NavigatorScope(
      select: _select,
      child: Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _slot,
              children: [
                for (final s in const [0, 1, 2, 3, 4])
                  (_built.contains(s) && s != 2) ? _page(s) : const SizedBox.shrink(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNav(
              slot: _slot,
              onSelect: _select,
              onCart: () => showCartSheet(context),
              ordersBadge: 0,
            ),
          ),
        ],
      ),
    )));
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.slot, required this.onSelect, required this.onCart, required this.ordersBadge});
  final int slot;
  final ValueChanged<int> onSelect;
  final VoidCallback onCart;
  final int ordersBadge;

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final inset = MediaQuery.paddingOf(context).bottom;
    final line = dark ? const Color(0xFF3A3A3A) : const Color(0xFFEAEAEA);
    final badge = dark ? const Color(0xFFE46D62) : const Color(0xFFD03025);

    final items = <_NavItem>[
      _NavItem('Accueil', AppIcons.homeOutline, AppIcons.home),
      _NavItem('Portefeuille', AppIcons.walletOutline, AppIcons.wallet),
      _NavItem('', AppIcons.basket, AppIcons.basket),
      _NavItem('Commandes', AppIcons.bookOutline, AppIcons.book, badge: ordersBadge > 0 ? ordersBadge : null),
      _NavItem('Profil', AppIcons.userOutline, AppIcons.user),
    ];

    return Container(
      height: 78.8 + inset,
      decoration: BoxDecoration(color: c.background, border: Border(top: BorderSide(color: line))),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = (box.maxWidth - 24) / 5;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Indicateur actif qui glisse d'un onglet a l'autre.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: 12 + slot * w + (w - 40) / 2,
                top: -1,
                child: AnimatedOpacity(
                  opacity: slot == 2 ? 0 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 40,
                    height: 3.6,
                    decoration: BoxDecoration(
                      color: c.title,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, inset),
                child: Row(
                  children: [
                    for (var i = 0; i < 5; i++)
                      Expanded(
                        child: i == 2
                            ? const SizedBox.shrink()
                            : _NavButton(
                                item: items[i],
                                active: slot == i,
                                badgeColor: badge,
                                onTap: () => onSelect(i),
                              ),
                      ),
                  ],
                ),
              ),
              Positioned(
                top: -8,
                left: 0,
                right: 0,
                child: Center(child: CartButton(onTap: onCart)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.activeIcon, {this.badge});
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int? badge;
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.active, required this.badgeColor, required this.onTap});
  final _NavItem item;
  final bool active;
  final Color badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: active ? c.title : c.subtitle),
          duration: const Duration(milliseconds: 220),
          builder: (context, color, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(active ? item.activeIcon : item.icon, size: 24, color: color),
                  if (item.badge != null)
                    Positioned(
                      top: -6,
                      right: -9,
                      child: Container(
                        width: 16,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                        child: Text(
                          '${item.badge}',
                          style: const TextStyle(
                            fontFamily: _inter,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            height: 1,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: active
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: _inter,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.8,
                            height: 1.2,
                            letterSpacing: -0.2,
                            color: color,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      )
                    : const SizedBox(width: 0, height: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartButton extends StatefulWidget {
  const CartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.94 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: dark
                ? null
                : const [BoxShadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 6))],
          ),
          child: Icon(AppIcons.basket, size: 28, color: c.onPrimary),
        ),
      ),
    );
  }
}
