import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldP = TextEditingController();
  final _newP = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer mot de passe')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _oldP, obscureText: true, decoration: const InputDecoration(labelText: 'Ancien mot de passe')),
            TextField(controller: _newP, obscureText: true, decoration: const InputDecoration(labelText: 'Nouveau mot de passe')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final u = ref.read(authProvider)!;
                final ok = await ref.read(userRepositoryProvider).changePassword(
                  userId: u.id, oldPassword: _oldP.text, newPassword: _newP.text,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Succès' : 'Échec')));
                  if (ok) Navigator.pop(context);
                }
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
