import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';
import '../../domain/models/credential_metadata.dart';
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
    final visibleCredentials = vm.filteredCredentials;

    return Scaffold(
      appBar: AppBar(
        title: Text(sessionVm.currentVault?.name ?? 'CredenSafe'),
        actions: [
          IconButton(
            onPressed: () => AppNavigator.toPasswordGenerator(context),
            icon: const Icon(Icons.password),
            tooltip: 'Generador',
          ),
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
            : visibleCredentials.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SearchField(viewModel: vm),
                  const SizedBox(height: 96),
                  const Icon(Icons.search_off, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    'No encontramos credenciales con ese nombre',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _SearchField(viewModel: vm);
                  }
                  final item = visibleCredentials[index - 1];
                  return _CredentialTile(item: item);
                },
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemCount: visibleCredentials.length + 1,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            AppNavigator.toPasswordGenerator(context);
          }
          if (index == 2) {
            AppNavigator.toSecurityActivity(context);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.key), label: 'Credenciales'),
          BottomNavigationBarItem(
            icon: Icon(Icons.password),
            label: 'Generador',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Seguridad',
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.viewModel});

  final CredentialListViewModel viewModel;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.viewModel.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.viewModel.searchQuery) {
      _controller.text = widget.viewModel.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.viewModel.updateSearchQuery,
      decoration: InputDecoration(
        labelText: 'Buscar por aplicación',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.viewModel.hasActiveSearch
            ? IconButton(
                onPressed: widget.viewModel.clearSearch,
                icon: const Icon(Icons.close),
                tooltip: 'Limpiar búsqueda',
              )
            : null,
      ),
    );
  }
}

class _CredentialTile extends StatelessWidget {
  const _CredentialTile({required this.item});

  final CredentialMetadata item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(item.appName.characters.first.toUpperCase()),
        ),
        title: Text(item.appName),
        subtitle: Text(
          [
            item.accountLabel,
            item.emailHint,
            item.loginHint,
          ].where((e) => e != null && e.isNotEmpty).join(' • '),
        ),
        trailing: item.isFavorite
            ? const Icon(Icons.star)
            : const Icon(Icons.chevron_right),
        onTap: () async {
          final detailVm = context.read<CredentialDetailViewModel>();
          final listVm = context.read<CredentialListViewModel>();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: detailVm,
                child: CredentialDetailPage(credentialId: item.id),
              ),
            ),
          );
          if (context.mounted) {
            await listVm.load();
          }
        },
      ),
    );
  }
}
