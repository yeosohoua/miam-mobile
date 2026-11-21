import 'package:flutter/material.dart';

import '../../../../../../core/api/api_client.dart';
import '../../../../../../core/api/erp_api.dart';
import '../../../../../../core/api/erp_stores.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/sub_page.dart';

/// Historique des mouvements du compte (recharges, achats, remboursements).
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<TransactionErp>? _liste;
  String? _err;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final l = await ErpApi.transactions(WalletStore.instance.inscritId);
      if (mounted) setState(() => _liste = l);
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final l = _liste;
    Widget corps;
    if (_err != null) {
      corps = Padding(padding: const EdgeInsets.all(24), child: Text(_err!, style: interStyle(c.error, size: 14)));
    } else if (l == null) {
      corps = const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    } else if (l.isEmpty) {
      corps = Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Center(child: Text('Aucune transaction pour le moment.', style: interStyle(c.subtitle, size: 15))),
      );
    } else {
      corps = Column(children: [
        for (final t in l)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.divider, width: 0.7))),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.libelle, style: interStyle(c.title, size: 14.4, w: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(dateHeure(t.date), style: interStyle(p.mutedText, size: 12.4)),
                ]),
              ),
              Text(
                '${t.montant > 0 ? '+' : ''}${fcfa(t.montant)}',
                style: interStyle(t.montant >= 0 ? const Color(0xFF1E9E5A) : p.coral, size: 14.4, w: FontWeight.w600),
              ),
            ]),
          ),
      ]);
    }
    return SubPage(title: 'Historique', child: corps);
  }
}
