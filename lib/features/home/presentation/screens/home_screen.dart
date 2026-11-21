import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/erp_api.dart';
import '../../../../core/api/erp_session.dart';
import '../../../../core/api/erp_stores.dart';
import '../../../../core/router/fade_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../login/presentation/screens/welcome_screen.dart';
import '../../../navigator/presentation/navigator_scope.dart';
import '../widgets/home_cards.dart';
import '../widgets/home_data.dart';
import '../widgets/home_header.dart';

/// Accueil : photo + "Bonjour <nom>", solde, categories, menus de la semaine, meilleures offres (donnees de l'ERP).
/// [guest] = visiteur : contenu de demonstration, clic sur l'avatar -> ecran de connexion.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.guest = false});
  final bool guest;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CategorieErp> _cats = const [];
  List<JourSemaine> _jours = const [];
  List<ArticleErp> _articles = const [];
  String? _photo;
  bool _charge = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    if (!widget.guest && ErpSession.instance.isSignedIn) {
      WalletStore.instance.addListener(_maj);
      _charger();
    }
  }

  @override
  void dispose() {
    WalletStore.instance.removeListener(_maj);
    super.dispose();
  }

  void _maj() {
    if (mounted) setState(() {});
  }

  Future<void> _charger() async {
    try {
      WalletStore.instance.load();
      final r = await Future.wait<Object?>([
        ErpApi.categories(),
        ErpApi.semaine(),
        ErpApi.articles(),
        ErpApi.photo().then<String?>((v) => v).catchError((_) => null),
      ]);
      if (!mounted) return;
      setState(() {
        _cats = r[0] as List<CategorieErp>;
        _jours = (r[1] as List<JourSemaine>).where((j) => j.libelles.isNotEmpty).toList();
        _articles = (r[2] as List<ArticleErp>).take(8).toList();
        _photo = r[3] as String?;
        _charge = true;
        _err = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final guest = widget.guest;
    final reel = !guest && ErpSession.instance.isSignedIn;
    final p = AppPalette(context);
    final c = MiamColors.of(context);
    final dark = p.dark;
    final mq = MediaQuery.of(context);
    final inset = mq.padding.top;
    final bottom = guest ? 16.0 + 64 + 24 : 78.8 + mq.padding.bottom + 24;
    final user = guest ? HomeDemoData.guestUser : (reel ? HomeUser(name: ErpSession.instance.name, avatarUrl: _photo) : HomeDemoData.user);
    final address = guest ? HomeDemoData.guestAddress : (reel ? ErpSession.instance.etablissement : HomeDemoData.address);
    final solde = WalletStore.instance.solde;

    final categories = reel ? _cats.map((k) => HomeCategory(k.nom, imageUrl: k.image)).toList() : HomeDemoData.categories;
    final menus = reel
        ? _jours
            .map((j) => HomeVendor(
                  name: majuscule(dateLongue(j.date)),
                  description: j.plats.isEmpty ? j.libelles.join(' · ') : j.plats.take(6).join(', '),
                  eta: j.libelles.join(' · '),
                  logoColor: const Color(0xFFE7F1EC),
                  express: false,
                  imageUrl: j.image,
                ))
            .toList()
        : HomeDemoData.popularVendors;
    final offres = reel
        ? _articles
            .map((a) => HomeOffer(
                  discount: a.categorie ?? 'Article',
                  vendor: ErpSession.instance.etablissement,
                  vendorColor: const Color(0xFF1E1B3A),
                  name: a.nom,
                  description: '',
                  price: fcfa(a.prix),
                  oldPrice: '',
                  imageUrl: a.image,
                ))
            .toList()
        : HomeDemoData.offers;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: c.background,
        body: RefreshIndicator(
          onRefresh: reel ? _charger : () async {},
          edgeOffset: inset + 143,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeHeaderDelegate(
                  inset: inset,
                  user: user,
                  address: address,
                  guest: guest,
                  onAvatarTap: guest
                      ? () => Navigator.of(context).pushAndRemoveUntil(fadeRoute<void>(const WelcomeScreen()), (_) => false)
                      : () => NavigatorScope.maybeOf(context)?.select(4),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16.8, 16, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (reel && solde != null) ...[
                      GestureDetector(
                        onTap: () => NavigatorScope.maybeOf(context)?.select(1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: p.tile, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
                          child: Row(children: [
                            Icon(AppIcons.wallet, size: 22, color: c.title),
                            const SizedBox(width: 10),
                            Text('Solde', style: interStyle(p.mutedText, size: 13.4)),
                            const Spacer(),
                            Text(fcfa(solde), style: dmStyle(c.title, size: 18, w: FontWeight.w600, ls: -0.4)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (_err != null) ...[
                      Text(_err!, style: interStyle(c.error, size: 13)),
                      const SizedBox(height: 12),
                    ],
                    Text('Catégories', style: sectionTitle(c.title)),
                    const SizedBox(height: 15),
                    if (reel && _charge && categories.isEmpty)
                      Text('Aucune catégorie pour le moment.', style: interStyle(p.mutedText, size: 13.4))
                    else
                      CategoriesGrid(
                        items: categories,
                        onTap: reel ? (k) => Navigator.of(context).pushNamed('/articles', arguments: k.name) : null,
                      ),
                    const SizedBox(height: 28),
                    Text('Les menus de la semaine', style: sectionTitle(c.title)),
                    const SizedBox(height: 16),
                    if (reel && _charge && menus.isEmpty) Text('Aucun menu publié cette semaine.', style: interStyle(p.mutedText, size: 13.4)),
                  ]),
                ),
              ),
              if (menus.isNotEmpty)
                SliverToBoxAdapter(
                  child: VendorsList(
                    items: menus,
                    onTap: reel
                        ? (v) {
                            final j = _jours.where((x) => majuscule(dateLongue(x.date)) == v.name);
                            if (j.isNotEmpty) Navigator.of(context).pushNamed('/shop', arguments: {'date': j.first.date});
                          }
                        : null,
                  ),
                ),
              if (offres.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 25, 16, 17.7),
                  sliver: SliverToBoxAdapter(
                    child: Row(children: [
                      Icon(AppIcons.offer, size: 20, color: c.title),
                      const SizedBox(width: 8),
                      Text('Meilleures offres', style: sectionTitle(c.title)),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: OffersList(
                    items: offres,
                    onTap: reel
                        ? (o) {
                            final a = _articles.where((x) => x.nom == o.name);
                            if (a.isNotEmpty) Navigator.of(context).pushNamed('/product', arguments: a.first);
                          }
                        : null,
                  ),
                ),
              ],
              SliverToBoxAdapter(child: SizedBox(height: bottom)),
            ],
          ),
        ),
      ),
    );
  }
}
