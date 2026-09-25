import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/preferences/shared_preference_manager.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../data/api/server_environment.dart';

/// Shows the Move Server bottom sheet.
/// After selecting a new server, clears auth and restarts the app from splash.
void showMoveServerBottomSheet(BuildContext context, WidgetRef ref) {
  final sharedPrefAsync = ref.read(sharedPreferenceManagerProvider);
  if (!sharedPrefAsync.hasValue) return;
  final sharedPref = sharedPrefAsync.value!;

  final currentEnv = sharedPref.getServerEnvironment();
  final savedLocalhost = sharedPref.getLocalBaseUrl();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _MoveServerContent(
      currentEnvironment: currentEnv,
      savedLocalhost: savedLocalhost,
      sharedPref: sharedPref,
      onServerChanged: () {
        ref.invalidate(serverConfigInitializerProvider);
        ref.invalidate(goRouterProvider);
      },
    ),
  );
}

class _MoveServerContent extends StatefulWidget {
  final ServerEnvironment currentEnvironment;
  final String savedLocalhost;
  final SharedPreferenceManager sharedPref;
  final VoidCallback onServerChanged;

  const _MoveServerContent({
    required this.currentEnvironment,
    required this.savedLocalhost,
    required this.sharedPref,
    required this.onServerChanged,
  });

  @override
  State<_MoveServerContent> createState() => _MoveServerContentState();
}

class _MoveServerContentState extends State<_MoveServerContent> {
  late ServerEnvironment _selected;
  late TextEditingController _localhostController;

  static const _environments = ServerEnvironment.values;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentEnvironment;
    _localhostController = TextEditingController(text: widget.savedLocalhost);
  }

  @override
  void dispose() {
    _localhostController.dispose();
    super.dispose();
  }

  bool _isValidIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  Future<void> _onSet() async {
    // Same server — just dismiss
    if (_selected == widget.currentEnvironment &&
        (_selected != ServerEnvironment.local ||
            _localhostController.text == widget.savedLocalhost)) {
      Navigator.pop(context);
      return;
    }

    // Validate IP for local before doing anything destructive
    final localBaseUrl = _localhostController.text.trim();
    if (_selected == ServerEnvironment.local) {
      if (!_isValidIP(localBaseUrl)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid IP address')),
        );
        return;
      }
    }

    // Logout first: clear all stored user data (UserDefaults), THEN apply the
    // new server. Order matters — clearAll() wipes everything, so the server
    // settings must be written after it.
    await widget.sharedPref.clearAll();
    await widget.sharedPref.setServerEnvironment(_selected);
    if (_selected == ServerEnvironment.local) {
      await widget.sharedPref.setLocalBaseUrl(localBaseUrl);
    }

    if (!mounted) return;
    Navigator.pop(context);
    widget.onServerChanged();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                'Move To Server',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Server radio options
            RadioGroup<ServerEnvironment>(
              groupValue: _selected,
              onChanged: (value) {
                if (value != null) setState(() => _selected = value);
              },
              child: Column(
                children: [
                  for (final env in _environments)
                    RadioListTile<ServerEnvironment>(
                      title: Text(
                        env.name[0].toUpperCase() + env.name.substring(1),
                      ),
                      value: env,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                ],
              ),
            ),

            // IP address field (only visible for local)
            if (_selected == ServerEnvironment.local) ...[
              const SizedBox(height: 12),
              Text(
                'Enter IP Address only (ex. 192.168.0.100)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _localhostController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Set + Cancel buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _onSet,
                    child: const Text('Set'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
