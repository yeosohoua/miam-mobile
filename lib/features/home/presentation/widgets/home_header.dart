// PATCH-25
import 'package:miam_assets/miam_assets.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/net_image.dart';
import '../../../navigator/presentation/navigator_scope.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import 'home_data.dart';

const _inter = 'packages/miam_assets/Inter';

/// En-tete de l'accueil: carte arrondie avec motif, qui se reduit au scroll
/// jusqu'a ne garder que la barre de recherche (epinglee).
class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  HomeHeaderDelegate({
    required this.inset,
    required this.user,
    required this.address,
    this.guest = false,
    this.onAvatarTap,
  });
  final double inset;
  final HomeUser user;
  final String address;
  final bool guest;
  final VoidCallback? onAvatarTap;

  // Mesures (384 dp): ouvert 225 dp, reduit 102.5 dp, pour une barre d'etat de 32 dp.
  @override
  double get maxExtent => inset + 143.1;
  @override
  double get minExtent => inset + 70.5;

  @override
  bool shouldRebuild(covariant HomeHeaderDelegate old) =>
      old.inset != inset || old.user != user || old.address != address || old.guest != guest;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Le contenu est un widget a part: il se reconstruit quand le theme change
    // (un delegate de sliver ne le ferait pas), donc plus de couleurs perimees.
    return HomeHeaderContent(
      inset: inset,
      user: user,
      address: address,
      shrinkOffset: shrinkOffset,
      guest: guest,
      onAvatarTap: onAvatarTap,
    );
  }
}

class HomeHeaderContent extends StatelessWidget {
  const HomeHeaderContent({
    super.key,
    required this.inset,
    required this.user,
    required this.address,
    required this.shrinkOffset,
    this.guest = false,
    this.onAvatarTap,
  });
  final double inset;
  final HomeUser user;
  final String address;
  final double shrinkOffset;
  final bool guest;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    const range = 72.6;
    final t = (shrinkOffset / range).clamp(0.0, 1.0);
    final fade = (1 - t * 2.4).clamp(0.0, 1.0);
    final line = dark ? const Color(0xFF6E6E6E) : const Color(0xFFDEDEDE);
    final doodle = dark ? const Color(0xFF2E4A8C) : null;

    Widget pattern = Image.asset(
      MiamAssets.shapes.headerBackground,
      package: 'miam_assets',
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      opacity: AlwaysStoppedAnimation<double>(dark ? 0.55 : 0.8),
    );
    if (doodle != null) {
      pattern = ColorFiltered(colorFilter: ColorFilter.mode(doodle, BlendMode.srcIn), child: pattern);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 4,
          right: 4,
          top: 4,
          bottom: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: ColoredBox(color: c.field, child: RepaintBoundary(child: pattern)),
          ),
        ),
        // Avatar, nom, cloche.
        Positioned(
          left: 20,
          right: 20,
          top: inset + 14 - shrinkOffset * 0.5,
          height: 49,
          child: IgnorePointer(
            ignoring: fade < 0.2,
            child: Opacity(
              opacity: fade,
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAvatarTap ?? () => NavigatorScope.maybeOf(context)?.select(4),
                    child: ClipOval(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: guest
                            // Visiteur: pastille neutre avec le pictogramme utilisateur, sans photo.
                            ? ColoredBox(
                                color: dark ? const Color(0xFF191919) : const Color(0xFFF6F6F6),
                                child: Center(child: Icon(AppIcons.user, size: 20, color: c.title)),
                              )
                            : (user.avatarUrl != null
                                ? NetImage(url: user.avatarUrl, placeholder: dark ? const Color(0xFF191919) : const Color(0xFFF6F6F6))
                                : ColoredBox(
                                    color: dark ? const Color(0xFF191919) : const Color(0xFFF6F6F6),
                                    child: Center(child: Icon(AppIcons.user, size: 20, color: c.title)),
                                  )),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      user.name.isEmpty ? 'Bonjour 👋' : 'Bonjour ${user.name} 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: _inter,
                        fontWeight: FontWeight.w500,
                        fontSize: 13.9,
                        height: 1.2,
                        letterSpacing: -0.3,
                        color: c.title,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context, rootNavigator: true).push(NotificationsScreen.route()),
                    child: Container(
                      width: 49,
                      height: 49,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: line),
                      ),
                      child: Icon(AppIcons.bell, size: 24, color: c.title),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Recherche (epinglee).
        Positioned(
          left: 20,
          right: 20,
          bottom: 16.5,
          height: 46.6,
          child: _SearchBox(line: line),
        ),
      ],
    );
  }
}


/// Barre de recherche saisissable: contour renforce quand elle a le focus.
class _SearchBox extends StatefulWidget {
  const _SearchBox({required this.line});
  final Color line;
  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  final _focus = FocusNode();
  final _ctl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    final on = _focus.hasFocus;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focus.requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12.8),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: on ? c.title : widget.line, width: on ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(AppIcons.search, size: 22, color: on ? c.title : c.subtitle),
            const SizedBox(width: 17),
            Expanded(
              child: Material(
                type: MaterialType.transparency,
                child: TextField(
                  controller: _ctl,
                  focusNode: _focus,
                  textInputAction: TextInputAction.search,
                  cursorColor: c.caret,
                  style: TextStyle(fontFamily: _inter, fontSize: 13.8, height: 1.2, letterSpacing: -0.3, color: c.title),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Rechercher',
                    hintStyle: TextStyle(fontFamily: _inter, fontSize: 13.8, height: 1.2, letterSpacing: -0.3, color: c.subtitle),
                  ),
                ),
              ),
            ),
            Icon(AppIcons.filters, size: 22, color: c.subtitle),
          ],
        ),
      ),
    );
  }
}
