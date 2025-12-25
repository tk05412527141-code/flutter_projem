import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_projem/features/home/presentation/providers/home_provider.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Veriyi dinle
    final userAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profesyonel Yapı')),
      body: userAsync.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) => ListTile(title: Text(users[index].name)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata oluştu: $err')),
      ),
    );
  }
}