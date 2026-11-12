import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class MandatoryChangePasswordScreen extends ConsumerStatefulWidget {
  const MandatoryChangePasswordScreen({super.key});

  @override
  ConsumerState<MandatoryChangePasswordScreen> createState() => _MandatoryChangePasswordScreenState();
}

class _MandatoryChangePasswordScreenState extends ConsumerState<MandatoryChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fnCtrl = TextEditingController(text: 'Admin');
  final _lnCtrl = TextEditingController();
  final _uCtrl = TextEditingController();
  final _pCtrl = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final err = await ref.read(authProvider.notifier).completeMandatoryUpdate(
      newUsername: _uCtrl.text.trim(),
      newPassword: _pCtrl.text.trim(),
      firstName: _fnCtrl.text.trim(),
      lastName: _lnCtrl.text.trim(),
    );
    if (!mounted) return;
    if (err == null) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Configuration Initiale')),
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
                TextFormField(controller: _uCtrl, decoration: const InputDecoration(labelText: 'Nouveau Login')),
                const SizedBox(height: 12),
                TextFormField(controller: _pCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Nouveau Mot de passe')),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _submit, child: const Text('Enregistrer et continuer')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
