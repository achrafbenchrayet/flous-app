import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _fnCtrl = TextEditingController();
  final _lnCtrl = TextEditingController();
  final _bCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final u = ref.read(authProvider)!;
    _fnCtrl.text = u.firstName;
    _lnCtrl.text = u.lastName;
    _bCtrl.text = (u.initialBalance / 1000.0).toStringAsFixed(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier profil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _fnCtrl, decoration: const InputDecoration(labelText: 'Prénom')),
            TextField(controller: _lnCtrl, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(controller: _bCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Solde initial (DT)')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final u = ref.read(authProvider)!;
                await ref.read(userRepositoryProvider).updateUserProfile(
                  userId: u.id, firstName: _fnCtrl.text, lastName: _lnCtrl.text,
                  initialBalanceMillimes: CurrencyFormatter.parseToMillimes(_bCtrl.text),
                );
                await ref.read(authProvider.notifier).refreshCurrentUser();
                ref.invalidate(dashboardDataProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
