import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? initialTransaction;
  const AddTransactionScreen({super.key, this.initialTransaction});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _amtCtrl;
  late TextEditingController _descCtrl;
  String? _catId;
  String _pay = 'Espèces';

  @override
  void initState() {
    super.initState();
    final tx = widget.initialTransaction;
    _type = tx?.type ?? 'expense';
    _amtCtrl = TextEditingController(text: tx != null ? (tx.amount / 1000.0).toStringAsFixed(3) : '');
    _descCtrl = TextEditingController(text: tx?.description ?? '');
    _catId = tx?.categoryId;
    _pay = tx?.paymentMethod ?? 'Espèces';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _catId == null) return;
    final user = ref.read(authProvider)!;
    final repo = ref.read(transactionRepositoryProvider);
    final amt = CurrencyFormatter.parseToMillimes(_amtCtrl.text);
    final now = DateTime.now();

    if (widget.initialTransaction != null) {
      await repo.updateTransaction(
        id: widget.initialTransaction!.id,
        categoryId: _catId!,
        type: _type,
        amountMillimes: amt,
        description: _descCtrl.text,
        date: widget.initialTransaction!.date,
        time: widget.initialTransaction!.time,
        paymentMethod: _pay,
      );
    } else {
      await repo.addTransaction(
        userId: user.id,
        categoryId: _catId!,
        type: _type,
        amountMillimes: amt,
        description: _descCtrl.text,
        date: DateFormat('yyyy-MM-dd').format(now),
        time: DateFormat('HH:mm').format(now),
        paymentMethod: _pay,
      );
    }

    ref.invalidate(dashboardDataProvider);
    ref.invalidate(transactionsListProvider);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(categoriesListProvider(_type));

    return Scaffold(
      appBar: AppBar(title: Text(widget.initialTransaction != null ? 'Modifier' : 'Ajouter Opération')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _type == 'expense' ? AppColors.expense : Colors.grey[300]),
                      onPressed: () => setState(() { _type = 'expense'; _catId = null; }),
                      child: const Text('DÉPENSE'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _type == 'income' ? AppColors.income : Colors.grey[300]),
                      onPressed: () => setState(() { _type = 'income'; _catId = null; }),
                      child: const Text('RECETTE'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant (DT)'),
                validator: (v) => (v == null || CurrencyFormatter.parseToMillimes(v) <= 0) ? 'Montant requis > 0' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 16),
              catsAsync.when(
                data: (cats) => DropdownButtonFormField<String>(
                  value: _catId,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _catId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur: $e'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _pay,
                decoration: const InputDecoration(labelText: 'Paiement'),
                items: ['Espèces', 'Carte bancaire', 'Virement', 'D17 / Portefeuille', 'Autre']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _pay = v!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Enregistrer')),
            ],
          ),
        ),
      ),
    );
  }
}
