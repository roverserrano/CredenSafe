import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/security_activity_viewmodel.dart';

class SecurityActivityPage extends StatefulWidget {
  const SecurityActivityPage({super.key});

  @override
  State<SecurityActivityPage> createState() => _SecurityActivityPageState();
}

class _SecurityActivityPageState extends State<SecurityActivityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityActivityViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SecurityActivityViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Actividad de seguridad')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, index) {
                final item = vm.events[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      item.eventStatus == 'success'
                          ? Icons.verified_user
                          : Icons.warning_amber_rounded,
                    ),
                    title: Text(item.eventType),
                    subtitle: Text(item.createdAt.toLocal().toString()),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: vm.events.length,
            ),
    );
  }
}
