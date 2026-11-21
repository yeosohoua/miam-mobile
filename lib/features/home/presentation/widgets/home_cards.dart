// PATCH-13
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/net_image.dart';
import 'home_data.dart';

const _inter = 'packages/miam_assets/Inter';
const _dmSans = 'packages/miam_assets/DM Sans';

/// Couleurs propres a l'accueil, selon le theme.
class HomePalette {
  HomePalette(BuildContext context)
      : dark = Theme.of(context).brightness == Brightness.dark,
        c = MiamColors.of(context);
  final bool dark;
  final MiamColors c;
  Color get tile => dark ? const Color(0xFF191919) : const Color(0xFFF6F6F6);
  Color get line => dark ? const Color(0xFF6E6E6E) : const Color(0xFFDEDEDE);
  Color get imagePlaceholder => dark ? const Color(0xFF262626) : const Color(0xFFEDEDED);
  Color get star => const Color(0xFFFFAA02);
  Color get green => const Color(0xFF23C55E);
}

TextStyle sectionTitle(Color color) => TextStyle(
      fontFamily: _dmSans,
      fontWeight: FontWeight.w500,
      fontSize: 17.5,
      height: 1.25,
      letterSpacing: -0.55,
      color: color,
    );

TextStyle _body(Color color, {double size = 12.5, FontWeight w = FontWeight.w400, double h = 1.3}) => TextStyle(
      fontFamily: _inter,
      fontWeight: w,
      fontSize: size,
      height: h,
      letterSpacing: -0.2,
      color: color,
    );

// ---------------------------------------------------------------- Orders card

class OrdersCard extends StatelessWidget {
  const OrdersCard({super.key, required this.data, this.onTap});
  final HomeOrdersSummary data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = HomePalette(context);
    final c = p.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 125,
        padding: const EdgeInsets.fromLTRB(16.5, 16, 16.5, 17),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
          boxShadow: p.dark
              ? null
              : const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 32,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${data.count} Orders',
                      style: TextStyle(
                        fontFamily: _dmSans,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        letterSpacing: -0.45,
                        color: c.title,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 24.0 * data.vendorColors.length + 32,
                    height: 32,
                    child: Stack(
                      children: [
                        for (var i = 0; i < data.vendorColors.length; i++)
                          Positioned(
                            left: i * 24.0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: data.vendorColors[i],
                                shape: BoxShape.circle,
                                border: Border.all(color: c.background, width: 1),
                              ),
                            ),
                          ),
                        Positioned(
                          left: data.vendorColors.length * 24.0,
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: p.dark ? const Color(0xFF262626) : const Color(0xFFE6E6E6),
                              shape: BoxShape.circle,
                            ),
                            child: Text('+${data.more}', style: _body(c.title, size: 12.5, w: FontWeight.w500, h: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text('Next: ${data.next}', style: _body(c.subtitle, size: 12, h: 1.3)),
            const SizedBox(height: 8),
            SizedBox(
              height: 22,
              child: Row(
                children: [
                  Icon(AppIcons.truck, size: 22, color: c.title),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: data.progress),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          minHeight: 6,
                          backgroundColor: p.line,
                          valueColor: AlwaysStoppedAnimation<Color>(c.title),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- Categories

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key, required this.items, this.onTap});
  final List<HomeCategory> items;
  final ValueChanged<HomeCategory>? onTap;

  @override
  Widget build(BuildContext context) {
    final p = HomePalette(context);
    final rows = <List<HomeCategory>>[];
    for (var i = 0; i < items.length; i += 5) {
      rows.add(items.sublist(i, i + 5 > items.length ? items.length : i + 5));
    }
    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 18),
          Row(
            children: [
              for (var i = 0; i < 5; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: i < rows[r].length
                      ? _CategoryCell(item: rows[r][i], p: p, onTap: onTap)
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _CategoryCell extends StatelessWidget {
  const _CategoryCell({required this.item, required this.p, this.onTap});
  final HomeCategory item;
  final HomePalette p;
  final ValueChanged<HomeCategory>? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null ? null : () => onTap!(item),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: EdgeInsets.zero,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: p.tile),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: NetImage(url: item.imageUrl, placeholder: Colors.transparent, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 30,
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _body(p.c.title, size: 12, h: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- Vendor cards

class VendorsList extends StatelessWidget {
  const VendorsList({super.key, required this.items, this.onTap});
  final List<HomeVendor> items;
  final ValueChanged<HomeVendor>? onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width * 0.778;
    return SizedBox(
      height: 249,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 5),
        itemBuilder: (_, i) => SizedBox(width: w, child: VendorCard(vendor: items[i], onTap: onTap == null ? null : () => onTap!(items[i]))),
      ),
    );
  }
}

class VendorCard extends StatelessWidget {
  const VendorCard({super.key, required this.vendor, this.onTap});
  final HomeVendor vendor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = HomePalette(context);
    final c = p.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8.7, 8, 7),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
          boxShadow: p.dark
              ? null
              : const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: NetImage(url: vendor.imageUrl, placeholder: p.imagePlaceholder),
                    ),
                  ),
                  if (vendor.express)
                    Positioned(
                      left: 4.7,
                      top: 4.7,
                      child: Container(
                        height: 24.4,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: p.dark ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(AppIcons.bolt, size: 14, color: p.dark ? Colors.black : Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Express delivery',
                              style: _body(p.dark ? Colors.black : Colors.white, size: 12.4, w: FontWeight.w500, h: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    left: 4.7,
                    bottom: -25,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: vendor.logoColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.background, width: 2),
                      ),
                      child: ClipOval(child: NetImage(url: vendor.logoUrl, placeholder: vendor.logoColor)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 18,
              child: vendor.rating == null
                  ? null
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.star, size: 14, color: p.star),
                          const SizedBox(width: 4),
                          Text(vendor.rating!.toStringAsFixed(1), style: _body(p.star, size: 12.4, w: FontWeight.w500, h: 1)),
                          const SizedBox(width: 6),
                          Text('(${vendor.ratingCount ?? 0})', style: _body(c.subtitle, size: 12.4, h: 1)),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 2),
            Text(
              vendor.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _body(c.title, size: 14.5, w: FontWeight.w500, h: 1.3),
            ),
            const SizedBox(height: 2),
            Text(
              vendor.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _body(c.subtitle, size: 12.4, h: 1.3),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(AppIcons.clock, size: 14, color: c.subtitle),
                const SizedBox(width: 6),
                Text(vendor.eta, style: _body(c.subtitle, size: 12.4, h: 1.2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Offer cards

class OffersList extends StatelessWidget {
  const OffersList({super.key, required this.items, this.onTap});
  final List<HomeOffer> items;
  final ValueChanged<HomeOffer>? onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width * 0.453;
    return SizedBox(
      height: 255,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 5),
        itemBuilder: (_, i) => SizedBox(width: w, child: OfferCard(offer: items[i], onTap: onTap == null ? null : () => onTap!(items[i]))),
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, this.onTap});
  final HomeOffer offer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = HomePalette(context);
    final c = p.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 7.5),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
          boxShadow: p.dark
              ? null
              : const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 112,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: NetImage(url: offer.imageUrl, placeholder: Colors.transparent, fit: BoxFit.contain)),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      height: 24.4,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: p.green, borderRadius: BorderRadius.circular(8)),
                      child: Text(offer.discount, style: _body(Colors.white, size: 13, w: FontWeight.w600, h: 1)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Container(
              height: 25,
              padding: const EdgeInsets.only(left: 4, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: p.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(color: offer.vendorColor, shape: BoxShape.circle),
                    child: ClipOval(child: NetImage(url: offer.vendorLogoUrl, placeholder: offer.vendorColor)),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      offer.vendor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _body(c.subtitle, size: 12.4, h: 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(offer.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: _body(c.title, size: 14.5, w: FontWeight.w500, h: 1.3)),
            const SizedBox(height: 2),
            Text(offer.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: _body(c.subtitle, size: 12.4, h: 1.3)),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  offer.price,
                  style: TextStyle(
                    fontFamily: _dmSans,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.5,
                    letterSpacing: -0.4,
                    color: c.title,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  offer.oldPrice,
                  style: _body(c.subtitle, size: 12, h: 1).copyWith(decoration: TextDecoration.lineThrough, decorationColor: c.subtitle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
