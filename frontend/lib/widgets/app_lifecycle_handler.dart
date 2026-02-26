import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/fidele_provider.dart';

/// Observe le cycle de vie de l'app et rafraîchit les données quand
/// l'utilisateur revient sur l'application (après avoir quitté ou mis en arrière-plan).
class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
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
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;

    final fideleProvider = context.read<FideleProvider>();
    await fideleProvider.fetchStats();
    await fideleProvider.fetchFideles();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
