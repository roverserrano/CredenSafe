import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/vault/presentation/viewmodels/session_viewmodel.dart';

class LifecycleLockWrapper extends StatefulWidget {
  const LifecycleLockWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<LifecycleLockWrapper> createState() => _LifecycleLockWrapperState();
}

class _LifecycleLockWrapperState extends State<LifecycleLockWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      context.read<SessionViewModel>().lockVault();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
