import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/theme_notifier.dart';
import '../interface/map_interface.dart';

/// A stateful wrapper that hosts the map widget.
///
/// This widget calls `manager.build()` ONCE and keeps it alive.
/// Parent rebuilds do NOT affect the map inside.
/// Automatically applies map style from settings based on current theme,
/// matching Kotlin's reactive `googleMapStyle` state pattern.
class MapHost extends ConsumerStatefulWidget {
  final MapInterface manager;

  const MapHost({super.key, required this.manager});

  @override
  ConsumerState<MapHost> createState() => _MapHostState();
}

class _MapHostState extends ConsumerState<MapHost> with WidgetsBindingObserver {
  late final Widget _mapWidget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapWidget = widget.manager.build();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyMapStyle();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.manager.detachView();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _applyMapStyle();
  }

  void _applyMapStyle() {
    if (!mounted) return;
    widget.manager.applyMapStyleFromSettings(
      MediaQuery.platformBrightnessOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme state — when user toggles theme mode in-app,
    // this triggers rebuild and re-applies map style automatically.
    // Equivalent to Kotlin's `googleMapStyle` mutableStateOf pattern.
    final themeState = ref.watch(themeProvider);
    final brightness = themeState.mode == AppThemeMode.dark
        ? Brightness.dark
        : themeState.mode == AppThemeMode.light
            ? Brightness.light
            : MediaQuery.platformBrightnessOf(context);
    widget.manager.applyMapStyleFromSettings(brightness);

    return _mapWidget;
  }
}
