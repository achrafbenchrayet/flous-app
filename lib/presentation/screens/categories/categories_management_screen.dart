import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';

class CategoriesManagementScreen extends ConsumerWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(categoriesListProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Catégories')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final nameCtrl = TextEditingController();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Nouvelle catégorie'),
              content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isNotEmpty) {
                      final u = ref.read(authProvider)!;
                      await ref.read(categoryRepositoryProvider).addCategory(
                        userId: u.id, name: nameCtrl.text, icon: 'category',
                        color: 0xFF0754D5, type: 'expense',
                      );
                      ref.invalidate(categoriesListProvider);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          );
        },
      ),
      body: catsAsync.when(
        data: (cats) => ListView.builder(
          itemCount: cats.length,
          itemBuilder: (context, idx) => ListTile(
            leading: Icon(Icons.circle, color: Color(cats[idx].color)),
            title: Text(cats[idx].name),
            subtitle: Text(cats[idx].type == 'expense' ? 'Dépense' : 'Recette'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
