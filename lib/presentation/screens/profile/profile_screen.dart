import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/settings_provider.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    if (user == null) return const Scaffold(body: Center(child: Text('Non connecté')));

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Paramètres')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(user.firstName[0])),
                title: Text('${user.firstName} ${user.lastName}'),
                subtitle: Text('Solde initial: ${CurrencyFormatter.formatMillimes(user.initialBalance)}'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Modifier profil'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Changer mot de passe'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                  ),
                  if (user.role == 'admin')
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('Gestion des comptes'),
                      onTap: () => context.push('/manage-users'),
                    ),
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Gestion des catégories'),
                    onTap: () => context.push('/manage-categories'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Exporter CSV'),
                    onTap: () async {
                      final p = await ref.read(backupServiceProvider).exportTransactionsToCSV(user.id);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exporté: $p')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.save),
                    title: const Text('Sauvegarde JSON'),
                    onTap: () async {
                      final p = await ref.read(backupServiceProvider).exportCompleteUserDataToJson(user.id);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sauvegardé: $p')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: AppColors.expense),
                    title: const Text('Réinitialiser les données', style: TextStyle(color: AppColors.expense)),
                    onTap: () async {
                      await ref.read(backupServiceProvider).resetUserData(user.id);
                      await ref.read(authProvider.notifier).refreshCurrentUser();
                      ref.invalidate(dashboardDataProvider);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Mode sombre'),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (v) => ref.read(settingsProvider.notifier).toggleTheme(v),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              child: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
