import 'package:csm_foundation_view/src/common/common_module.dart';
import 'package:csm_foundation_view/src/theme/theme_module.dart';
import 'package:flutter/material.dart' hide Theme;
import 'package:flutter/material.dart';

part 'widgets/private/csm_frame_indicator.dart';

/// Core class for [CSMApplication].
/// Defines a core fuctionallity class for [CSMApplication].
///
/// [ThemeBase] - The abstraction base for [CSMThemeBase] management and interface.
///
/// [CSMApplication] concept: the core of a foundation [COSMOS] project solution, it handles,
/// builds and manages everything related to the main features and tools provided by the package.
/// Replaces the usually used [MaterialApp] with a high level abtraction to generate easiest way projects implementations
/// context.
///
/// (@category Applications)
final class CSMApplication<ThemeBase extends CSMThemeBase> extends StatefulWidget {
  /// [CSMThemeBase] base implementation to use when no theme was reached.
  final ThemeBase? defaultTheme;

  /// Defines all possible [ThemeBase] implementations possible to the [ThemeManager].
  final List<ThemeBase> themes;

  /// Entry point [Widget] usually drawn when no [Routing] configuration given.
  final Widget? home;

  /// Entry point [Widget] builded usually drawn when no [Routing] configuration given.
  final Widget Function(BuildContext context)? homeBuilder;

  /// General application builder, to wrap all the [Routing] resolutions into this build.
  ///
  /// [context] - the current render tree context.
  ///
  /// [app] - the resolved [Routing] management resolution building the current app rendering.
  final Widget Function(BuildContext context, Widget? app)? builder;

  /// A delegate for [Routing] behavior.
  final RouterDelegate<Object>? routerDelegate;

  /// Custom configuration for [Routing] behavior.
  final RouterConfig<Object>? routerConfig;

  /// Wheter the application should listen and render the current [Frame].
  final bool listenFrame;

  /// Wheter the application should use legacy debug indicator banner.
  final bool useLegacyDebugBanner;

  /// Generates a new [CSMApplication] application.
  const CSMApplication({
    super.key,
    this.defaultTheme,
    this.homeBuilder,
    this.home,
    this.builder,
    this.routerConfig,
    this.routerDelegate,
    this.themes = const <Never>[],
    this.listenFrame = false,
    this.useLegacyDebugBanner = false,
  }) : assert(((home != null) != (homeBuilder != null)) || (home == null && homeBuilder == null), "The home widget and builder cannot be at the same time, must be just one or no one");

  /// Generates a new [CSMApplication] application.
  ///
  /// Based on a required [Routing] configuration or delegation.
  const CSMApplication.router({
    super.key,
    this.defaultTheme,
    this.builder,
    this.routerConfig,
    this.routerDelegate,
    this.themes = const <Never>[],
    this.listenFrame = false,
    this.useLegacyDebugBanner = false,
  })  : assert(routerConfig != null || routerDelegate != null, "Router config or Router delegate must be defined to use a router based Cosmos App"),
        homeBuilder = null,
        home = null;

  @override
  State<CSMApplication<CSMThemeBase>> createState() => _CSMApplicationState();
}

class _CSMApplicationState extends State<CSMApplication<CSMThemeBase>> {
  late final Widget? byHome;
  bool get _usesRouter => widget.routerDelegate != null || widget.routerConfig != null;

  late ValueNotifier<CSMThemeBase> listener;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    initTheme(widget.defaultTheme, widget.themes);
    listener = listenTheme;
    if (widget.home != null) byHome = widget.home;
    if (widget.homeBuilder != null) byHome = widget.homeBuilder?.call(context);

    const CSMAdvisor('COSMOS').message('Starting engines⚙️⚙️⚙️');
  }

  @override
  void didUpdateWidget(covariant CSMApplication<CSMThemeBase> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget buildApp() {
    return _usesRouter ? _buildFromRouter() : _build();
  }

  @override
  Widget build(BuildContext context) => buildApp();

  Widget _build() {
    return MaterialApp(
      home: byHome,
      builder: frameListener,
      restorationScopeId: 'scope-main',
      debugShowCheckedModeBanner: widget.useLegacyDebugBanner,
    );
  }

  Widget _buildFromRouter() {
    return MaterialApp.router(
      builder: frameListener,
      routerConfig: widget.routerConfig,
      routerDelegate: widget.routerDelegate,
      restorationScopeId: 'scope-main-router',
      debugShowCheckedModeBanner: widget.useLegacyDebugBanner,
    );
  }

  Widget frameListener(BuildContext ctx, Widget? child) {
    if (!widget.listenFrame) {
      return widget.builder!(context, child);
    }

    return ValueListenableBuilder<CSMThemeBase>(
      valueListenable: listener,
      builder: (BuildContext context, _, __) {
        return Stack(
          textDirection: TextDirection.ltr,
          children: <Widget>[
            widget.builder!(context, child),
            const Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: _CSMFrameIndicator(),
              ),
            ),
          ],
        );
      },
    );
  }
}