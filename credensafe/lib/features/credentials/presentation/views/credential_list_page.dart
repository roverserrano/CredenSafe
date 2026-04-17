import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';
import '../viewmodels/credential_detail_viewmodel.dart';
import '../viewmodels/credential_list_viewmodel.dart';
import 'credential_detail_page.dart';

class CredentialListPage extends StatefulWidget {
  const CredentialListPage({super.key});

  @override
  State<CredentialListPage> createState() => _CredentialListPageState();
}

class _CredentialListPageState extends State<CredentialListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CredentialListViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CredentialListViewModel>();
    final sessionVm = context.watch<SessionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(sessionVm.currentVault?.name ?? 'CredenSafe'),
        actions: [
          IconButton(
            onPressed: () => AppNavigator.toSecurityActivity(context),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () => AppNavigator.toSettings(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vm.credentials.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 120),
                      Icon(Icons.lock_outline, size: 64),
                      SizedBox(height: 12),
                      Text(
                        'Todavía no tienes credenciales guardadas',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = vm.credentials[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(item.appName.characters.first.toUpperCase()),
                          ),
                          title: Text(item.appName),
                          subtitle: Text(
                            [item.accountLabel, item.emailHint, item.loginHint]
                                .where((e) => e != null && e.isNotEmpty)
                                .join(' • '),
                          ),
                          trailing: item.isFavorite
                              ? const Icon(Icons.star)
                              : const Icon(Icons.chevron_right),
                          onTap: () async {
                            final detailVm = context.read<CredentialDetailViewModel>();
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: detailVm,
                                  child: CredentialDetailPage(
                                    credentialId: item.id,
                                  ),
                                ),
                              ),
                            );
                            if (context.mounted) {
                              await vm.load();
                            }
                          },
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemCount: vm.credentials.length,
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await AppNavigator.toCredentialForm(context);
          if (context.mounted) {
            await vm.load();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
    );
  }
}
