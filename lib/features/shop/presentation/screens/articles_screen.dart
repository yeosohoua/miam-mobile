import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/erp_api.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../widgets/articles_widgets.dart';

/// Articles de la carte : recherche + filtre par categorie. Argument de route : nom de categorie (String?).
class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});
  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  List<CategorieErp> _cats = const [];
  List<ArticleErp>? _articles;
  String? _cat;
  String _q = '';
  String? _err;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.isNotEmpty) _cat = arg;
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _articles = null;
      _err = null;
    });
    try {
      final r = await Future.wait([ErpApi.categories(), ErpApi.articles(categorie: _cat)]);
      if (!mounted) return;
      setState(() {
        _cats = r[0] as List<CategorieErp>;
        _articles = r[1] as List<ArticleErp>;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    }
  }

  Future<void> _choisir(String? nom) async {
    _cat = nom;
    try {
      setState(() => _articles = null);
      final l = await ErpApi.articles(categorie: nom);
      if (mounted) setState(() => _articles = l);
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final l = (_articles ?? const <ArticleErp>[]).where((a) => _q.isEmpty || a.nom.toLowerCase().contains(_q.toLowerCase())).toList();

    Widget puce(String label, bool sel, VoidCallback f) => GestureDetector(
          onTap: f,
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: sel ? c.primary : p.chipNeutral, borderRadius: BorderRadius.circular(10)),
            child: Text(label, style: interStyle(sel ? c.onPrimary : c.title, size: 13.4, w: FontWeight.w500)),
          ),
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: p.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: p.dark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(children: [
          Padding(
            padding: EdgeInsets.only(top: mq.padding.top + 8),
            child: Column(children: [
              SizedBox(
                height: 44,
                child: Stack(alignment: Alignment.center, children: [
                  Text('Articles', style: dmStyle(c.title, size: 15.6, ls: -0.47)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: SizedBox(width: 56, height: 44, child: Icon(AppIcons.arrowLeft, size: 24, color: c.title)),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: TextField(
                  cursorColor: c.caret,
                  style: interStyle(c.title, size: 14.4),
                  onChanged: (v) => setState(() => _q = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un article',
                    hintStyle: interStyle(p.mutedText, size: 14.4),
                    prefixIcon: Icon(AppIcons.search, size: 20, color: p.mutedText),
                    filled: true,
                    fillColor: p.tile,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.line)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.line)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.title)),
                  ),
                ),
              ),
              SizedBox(
                height: 36,
                child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
                  puce('Tout', _cat == null, () => _choisir(null)),
                  for (final k in _cats) puce(k.nom, _cat == k.nom, () => _choisir(k.nom)),
                ]),
              ),
              Expanded(
                child: _err != null
                    ? Center(child: Text(_err!, style: interStyle(c.error, size: 14)))
                    : _articles == null
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : l.isEmpty
                            ? Center(child: Text('Aucun article trouvé.', style: interStyle(c.subtitle, size: 15)))
                            : ListView.builder(
                                padding: EdgeInsets.fromLTRB(16, 4, 16, 90 + mq.padding.bottom),
                                itemCount: l.length,
                                itemBuilder: (_, i) => ArticleRow(article: l[i], onTap: () => Navigator.of(context).pushNamed('/product', arguments: l[i])),
                              ),
              ),
            ]),
          ),
          Positioned(left: 16, right: 16, bottom: 12 + mq.padding.bottom, child: const CartBar()),
        ]),
      ),
    );
  }
}
