import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

final usersListProvider = FutureProvider.autoDispose<List<UserModel>>((ref) => ref.watch(userRepositoryProvider).getAllUsers());

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersListProvider);
    final cur = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Utilisateurs')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await context.push('/register-user');
          ref.invalidate(usersListProvider);
        },
      ),
      body: usersAsync.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, idx) {
            final u = users[idx];
            return ListTile(
              title: Text('${u.firstName} ${u.lastName} (@${u.username})'),
              trailing: (cur?.id != u.id)
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await ref.read(userRepositoryProvider).deleteUser(u.id);
                        ref.invalidate(usersListProvider);
                      },
                    )
                  : const Text('Actuel'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
