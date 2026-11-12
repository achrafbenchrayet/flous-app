import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';

class RegisterUserScreen extends ConsumerStatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  ConsumerState<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends ConsumerState<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fnCtrl = TextEditingController();
  final _lnCtrl = TextEditingController();
  final _uCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  final _balCtrl = TextEditingController(text: '0.000');

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(userRepositoryProvider);
    await repo.createUser(
      firstName: _fnCtrl.text.trim(),
      lastName: _lnCtrl.text.trim(),
      username: _uCtrl.text.trim(),
      password: _pCtrl.text.trim(),
      initialBalanceMillimes: CurrencyFormatter.parseToMillimes(_balCtrl.text),
    );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel Utilisateur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _fnCtrl, decoration: const InputDecoration(labelText: 'Prénom')),
              const SizedBox(height: 12),
              TextFormField(controller: _lnCtrl, decoration: const InputDecoration(labelText: 'Nom')),
              const SizedBox(height: 12),
              TextFormField(controller: _uCtrl, decoration: const InputDecoration(labelText: 'Identifiant unique')),
              const SizedBox(height: 12),
              TextFormField(controller: _pCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
              const SizedBox(height: 12),
              TextFormField(controller: _balCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Solde de départ (DT)')),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _register, child: const Text('Créer le compte')),
            ],
          ),
        ),
      ),
    );
  }
}
