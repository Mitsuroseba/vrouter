part of '../main.dart';

/// See [VRouter.mode]
enum VRouterModes { hash, history }

/// This widget handles most of the routing work
/// It gives you access to the [routes] attribute where you can start
/// building your routes using [VRouteElement]s
///
/// Note that this widget also acts as a [MaterialApp] so you can pass
/// it every argument that you would expect in [MaterialApp]
class VRouter extends StatefulWidget
    with VRouteElement, VRouteElementWithoutPage {
  /// This list holds every possible routes of your app
  final List<VRouteElement> routes;

  /// If implemented, this becomes the default transition for every route transition
  /// except those who implement there own buildTransition
  /// Also see:
  ///   * [VRouteElement.buildTransition] for custom local transitions
  ///
  /// Note that if this is not implemented, every route which does not implement
  /// its own buildTransition will be given a default transition: this of a
  /// [MaterialPage] or a [CupertinoPage] depending on the platform
  final Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? buildTransition;

  /// The duration of [VRouter.buildTransition]
  final Duration? transitionDuration;

  /// The reverse duration of [VRouter.buildTransition]
  final Duration? reverseTransitionDuration;

  /// Two router mode are possible:
  ///    - "hash": This is the default, the url will be serverAddress/#/localUrl
  ///    - "history": This will display the url in the way we are used to, without
  ///       the #. However note that you will need to configure your server to make this work.
  ///       Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
  final VRouterModes mode;

  /// Called when a url changes, before the url is updated
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// [saveHistoryState] can be used to save a history state before leaving
  /// This history state will be restored if the user uses the back button
  /// You will find the saved history state in the [VRouteElementData] using
  /// [VRouter.of(context).historyState]
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouteElement.beforeLeave] for route level beforeLeave
  ///   * [VWidgetGuard.beforeLeave] for widget level beforeLeave
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(
    VRedirector vRedirector,
    void Function(Map<String, String> historyState) saveHistoryState,
  ) beforeLeave;

  /// This is called before the url is updated but after all beforeLeave are called
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouteElement.beforeEnter] for route level beforeEnter
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(VRedirector vRedirector) beforeEnter;

  /// This is called after the url and the historyState are updated
  /// You can't prevent the navigation anymore
  /// You can get the new route parameters, and queryParameters
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouteElement.afterEnter] for route level afterEnter
  ///   * [VWidgetGuard.afterEnter] for widget level afterEnter
  final void Function(BuildContext context, String? from, String to) afterEnter;

  /// Called when a pop event occurs
  /// A pop event can be called programmatically (with [VRouter.of(context).pop()])
  /// or by other widgets such as the appBar back button
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// The route you go to is calculated based on [VRouterState._defaultPop]
  ///
  /// Note that you should consider the pop cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Pop%20Events/onPop]
  ///
  /// Also see:
  ///   * [VRouteElement.onPop] for route level onPop
  ///   * [VWidgetGuard.onPop] for widget level onPop
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(VRedirector vRedirector) onPop;

  /// Called when a system pop event occurs.
  /// This happens on android when the system back button is pressed.
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// The route you go to is calculated based on [VRouterState._defaultPop]
  ///
  /// Note that you should consider the systemPop cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Pop%20Events/onSystemPop]
  ///
  /// Also see:
  ///   * [VRouteElement.onSystemPop] for route level onSystemPop
  ///   * [VWidgetGuard.onSystemPop] for widget level onSystemPop
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(VRedirector vRedirector) onSystemPop;

  /// This allows you to change the initial url
  ///
  /// The default is '/'
  final String initialUrl;

  VRouter({
    Key? key,
    required this.routes,
    this.afterEnter = VRouteElement._voidAfterEnter,
    this.beforeEnter = VRouteElement._voidBeforeEnter,
    this.beforeLeave = VRouteElement._voidBeforeLeave,
    this.onPop = VRouteElement._voidOnPop,
    this.onSystemPop = VRouteElement._voidOnSystemPop,
    this.buildTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.mode = VRouterModes.hash,
    this.initialUrl = '/',
    // Bellow are the MaterialApp parameters
    this.backButtonDispatcher,
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.theme,
    this.darkTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
  }) : super(key: key);

  @override
  VRouterState createState() => VRouterState();

  /// {@macro flutter.widgets.widgetsApp.backButtonDispatcher}
  final BackButtonDispatcher? backButtonDispatcher;

  /// {@macro flutter.widgets.widgetsApp.builder}
  ///
  /// Material specific features such as [showDialog] and [showMenu], and widgets
  /// such as [Tooltip], [PopupMenuButton], also require a [Navigator] to properly
  /// function.
  final TransitionBuilder? builder;

  /// {@macro flutter.widgets.widgetsApp.title}
  ///
  /// This value is passed unmodified to [WidgetsApp.title].
  final String? title;

  /// {@macro flutter.widgets.widgetsApp.onGenerateTitle}
  ///
  /// This value is passed unmodified to [WidgetsApp.onGenerateTitle].
  final GenerateAppTitle? onGenerateTitle;

  /// Default visual properties, like colors fonts and shapes, for this app's
  /// material widgets.
  ///
  /// A second [darkTheme] [ThemeData] value, which is used to provide a dark
  /// version of the user interface can also be specified. [themeMode] will
  /// control which theme will be used if a [darkTheme] is provided.
  ///
  /// The default value of this property is the value of [ThemeData.light()].
  ///
  /// See also:
  ///
  ///  * [themeMode], which controls which theme to use.
  ///  * [MediaQueryData.platformBrightness], which indicates the platform's
  ///    desired brightness and is used to automatically toggle between [theme]
  ///    and [darkTheme] in [MaterialApp].
  ///  * [ThemeData.brightness], which indicates the [Brightness] of a theme's
  ///    colors.
  final ThemeData? theme;

  /// The [ThemeData] to use when a 'dark mode' is requested by the system.
  ///
  /// Some host platforms allow the users to select a system-wide 'dark mode',
  /// or the application may want to offer the user the ability to choose a
  /// dark theme just for this application. This is theme that will be used for
  /// such cases. [themeMode] will control which theme will be used.
  ///
  /// This theme should have a [ThemeData.brightness] set to [Brightness.dark].
  ///
  /// Uses [theme] instead when null. Defaults to the value of
  /// [ThemeData.light()] when both [darkTheme] and [theme] are null.
  ///
  /// See also:
  ///
  ///  * [themeMode], which controls which theme to use.
  ///  * [MediaQueryData.platformBrightness], which indicates the platform's
  ///    desired brightness and is used to automatically toggle between [theme]
  ///    and [darkTheme] in [MaterialApp].
  ///  * [ThemeData.brightness], which is typically set to the value of
  ///    [MediaQueryData.platformBrightness].
  final ThemeData? darkTheme;

  /// The [ThemeData] to use when 'high contrast' is requested by the system.
  ///
  /// Some host platforms (for example, iOS) allow the users to increase
  /// contrast through an accessibility setting.
  ///
  /// Uses [theme] instead when null.
  ///
  /// See also:
  ///
  ///  * [MediaQueryData.highContrast], which indicates the platform's
  ///    desire to increase contrast.
  final ThemeData? highContrastTheme;

  /// The [ThemeData] to use when a 'dark mode' and 'high contrast' is requested
  /// by the system.
  ///
  /// Some host platforms (for example, iOS) allow the users to increase
  /// contrast through an accessibility setting.
  ///
  /// This theme should have a [ThemeData.brightness] set to [Brightness.dark].
  ///
  /// Uses [darkTheme] instead when null.
  ///
  /// See also:
  ///
  ///  * [MediaQueryData.highContrast], which indicates the platform's
  ///    desire to increase contrast.
  final ThemeData? highContrastDarkTheme;

  /// Determines which theme will be used by the application if both [theme]
  /// and [darkTheme] are provided.
  ///
  /// If set to [ThemeMode.system], the choice of which theme to use will
  /// be based on the user's system preferences. If the [MediaQuery.platformBrightnessOf]
  /// is [Brightness.light], [theme] will be used. If it is [Brightness.dark],
  /// [darkTheme] will be used (unless it is null, in which case [theme]
  /// will be used.
  ///
  /// If set to [ThemeMode.light] the [theme] will always be used,
  /// regardless of the user's system preference.
  ///
  /// If set to [ThemeMode.dark] the [darkTheme] will be used
  /// regardless of the user's system preference. If [darkTheme] is null
  /// then it will fallback to using [theme].
  ///
  /// The default value is [ThemeMode.system].
  ///
  /// See also:
  ///
  ///  * [theme], which is used when a light mode is selected.
  ///  * [darkTheme], which is used when a dark mode is selected.
  ///  * [ThemeData.brightness], which indicates to various parts of the
  ///    system what kind of theme is being used.
  final ThemeMode? themeMode;

  /// {@macro flutter.widgets.widgetsApp.color}
  final Color? color;

  /// {@macro flutter.widgets.widgetsApp.locale}
  final Locale? locale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// Internationalized apps that require translations for one of the locales
  /// listed in [GlobalMaterialLocalizations] should specify this parameter
  /// and list the [supportedLocales] that the application can handle.
  ///
  /// ```dart
  /// import 'package:flutter_localizations/flutter_localizations.dart';
  /// MaterialApp(
  ///   localizationsDelegates: [
  ///     // ... app-specific localization delegate[s] here
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///   ],
  ///   supportedLocales: [
  ///     const Locale('en', 'US'), // English
  ///     const Locale('he', 'IL'), // Hebrew
  ///     // ... other locales the app supports
  ///   ],
  ///   // ...
  /// )
  /// ```
  ///
  /// ## Adding localizations for a new locale
  ///
  /// The information that follows applies to the unusual case of an app
  /// adding translations for a language not already supported by
  /// [GlobalMaterialLocalizations].
  ///
  /// Delegates that produce [WidgetsLocalizations] and [MaterialLocalizations]
  /// are included automatically. Apps can provide their own versions of these
  /// localizations by creating implementations of
  /// [LocalizationsDelegate<WidgetsLocalizations>] or
  /// [LocalizationsDelegate<MaterialLocalizations>] whose load methods return
  /// custom versions of [WidgetsLocalizations] or [MaterialLocalizations].
  ///
  /// For example: to add support to [MaterialLocalizations] for a
  /// locale it doesn't already support, say `const Locale('foo', 'BR')`,
  /// one could just extend [DefaultMaterialLocalizations]:
  ///
  /// ```dart
  /// class FooLocalizations extends DefaultMaterialLocalizations {
  ///   FooLocalizations(Locale locale) : super(locale);
  ///   @override
  ///   String get okButtonLabel {
  ///     if (locale == const Locale('foo', 'BR'))
  ///       return 'foo';
  ///     return super.okButtonLabel;
  ///   }
  /// }
  ///
  /// ```
  ///
  /// A `FooLocalizationsDelegate` is essentially just a method that constructs
  /// a `FooLocalizations` object. We return a [SynchronousFuture] here because
  /// no asynchronous work takes place upon "loading" the localizations object.
  ///
  /// ```dart
  /// class FooLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  ///   const FooLocalizationsDelegate();
  ///   @override
  ///   Future<FooLocalizations> load(Locale locale) {
  ///     return SynchronousFuture(FooLocalizations(locale));
  ///   }
  ///   @override
  ///   bool shouldReload(FooLocalizationsDelegate old) => false;
  /// }
  /// ```
  ///
  /// Constructing a [MaterialApp] with a `FooLocalizationsDelegate` overrides
  /// the automatically included delegate for [MaterialLocalizations] because
  /// only the first delegate of each [LocalizationsDelegate.type] is used and
  /// the automatically included delegates are added to the end of the app's
  /// [localizationsDelegates] list.
  ///
  /// ```dart
  /// MaterialApp(
  ///   localizationsDelegates: [
  ///     const FooLocalizationsDelegate(),
  ///   ],
  ///   // ...
  /// )
  /// ```
  /// See also:
  ///
  ///  * [supportedLocales], which must be specified along with
  ///    [localizationsDelegates].
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/tutorials/internationalization/>.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// {@macro flutter.widgets.widgetsApp.localeListResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// {@macro flutter.widgets.LocaleResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  ///
  /// It is passed along unmodified to the [WidgetsApp] built by this widget.
  ///
  /// See also:
  ///
  ///  * [localizationsDelegates], which must be specified for localized
  ///    applications.
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/tutorials/internationalization/>.
  final Iterable<Locale>? supportedLocales;

  /// Turns on a performance overlay.
  ///
  /// See also:
  ///
  ///  * <https://flutter.dev/debugging/#performanceoverlay>
  final bool? showPerformanceOverlay;

  /// Turns on checkerboarding of raster cache images.
  final bool? checkerboardRasterCacheImages;

  /// Turns on checkerboarding of layers rendered to offscreen bitmaps.
  final bool? checkerboardOffscreenLayers;

  /// Turns on an overlay that shows the accessibility information
  /// reported by the framework.
  final bool? showSemanticsDebugger;

  /// {@macro flutter.widgets.widgetsApp.debugShowCheckedModeBanner}
  final bool? debugShowCheckedModeBanner;

  /// {@macro flutter.widgets.widgetsApp.shortcuts}
  /// {@tool snippet}
  /// This example shows how to add a single shortcut for
  /// [LogicalKeyboardKey.select] to the default shortcuts without needing to
  /// add your own [Shortcuts] widget.
  ///
  /// Alternatively, you could insert a [Shortcuts] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     shortcuts: <LogicalKeySet, Intent>{
  ///       ... WidgetsApp.defaultShortcuts,
  ///       LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.shortcuts.seeAlso}
  final Map<LogicalKeySet, Intent>? shortcuts;

  /// {@macro flutter.widgets.widgetsApp.actions}
  /// {@tool snippet}
  /// This example shows how to add a single action handling an
  /// [ActivateAction] to the default actions without needing to
  /// add your own [Actions] widget.
  ///
  /// Alternatively, you could insert a [Actions] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     actions: <Type, Action<Intent>>{
  ///       ... WidgetsApp.defaultActions,
  ///       ActivateAction: CallbackAction(
  ///         onInvoke: (Intent intent) {
  ///           // Do something here...
  ///           return null;
  ///         },
  ///       ),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.actions.seeAlso}
  final Map<Type, Action<Intent>>? actions;

  /// Turns on a [GridPaper] overlay that paints a baseline grid
  /// Material apps.
  ///
  /// Only available in checked mode.
  ///
  /// See also:
  ///
  ///  * <https://material.io/design/layout/spacing-methods.html>
  final bool? debugShowMaterialGrid;

  static LocalVRouterData of(BuildContext context) {
    final localVRouterData =
        context.dependOnInheritedWidgetOfExactType<LocalVRouterData>();
    if (localVRouterData == null) {
      throw FlutterError(
          'VRouter.of(context) was called with a context which does not contain a VRouter.\n'
          'The context used to retrieve VRouter must be that of a widget that '
          'is a descendant of a VRouter widget.');
    }
    return localVRouterData;
  }

  @override
  List<VRouteElement> get stackedRoutes => routes;
}

class VRouterState extends State<VRouter> {
  /// This is a context which contains the VRouter.
  /// It is used is VRouter.beforeLeave for example.
  late BuildContext _rootVRouterContext;

  /// Designates the number of page we navigated since
  /// entering the app.
  /// If is only used in the web to know where we are when
  /// the user interacts with the browser instead of the app
  /// (e.g back button)
  late int _serialCount;

  /// When set to true, urlToAppState will be ignored
  /// You must manually reset it to true otherwise it will
  /// be ignored forever.
  bool _ignoreNextBrowserCalls = false;

  /// When set to false, appStateToUrl will be "ignored"
  /// i.e. no new history entry will be created
  /// You must manually reset it to true otherwise it will
  /// be ignored forever.
  bool _doReportBackUrlToBrowser = true;

  /// Those are used in the root navigator
  /// They are here to prevent breaking animations
  final GlobalKey<NavigatorState> _navigatorKey;
  final HeroController _heroController;

  /// The child of this widget
  ///
  /// This will contain the navigator etc.
  //
  // When the app starts, before we process the '/' route, we display
  // nothing.
  // Ideally this should never be needed, or replaced with a splash screen
  // Should we add the option ?
  late VRoute _vRoute = VRoute(
    pages: [],
    pathParameters: {},
    vRouteElementNode: VRouteElementNode(widget, localPath: null),
    vRouteElements: [widget],
  );

  /// Every VWidgetGuard will be registered here
  List<VWidgetGuardMessageRoot> _vWidgetGuardMessagesRoot = [];

  VRouterState()
      : _navigatorKey = GlobalKey<NavigatorState>(),
        _heroController = HeroController();

  /// Url currently synced with the state
  /// This url can differ from the once of the browser if
  /// the state has been yet been updated
  String? url;

  /// Previous url that was synced with the state
  String? previousUrl;

  /// This state is saved in the browser history. This means that if the user presses
  /// the back or forward button on the navigator, this historyState will be the same
  /// as the last one you saved.
  ///
  /// It can be changed by using [context.vRouter.replaceHistoryState(newState)]
  Map<String, String> historyState = {};

  /// Maps all route parameters (i.e. parameters of the path
  /// mentioned as ":someId")
  Map<String, String> pathParameters = <String, String>{};

  /// Contains all query parameters (i.e. parameters after
  /// the "?" in the url) of the current url
  Map<String, String> queryParameters = <String, String>{};

  @override
  void initState() {
    // When the app starts, get the serialCount. Default to 0.
    _serialCount = (kIsWeb) ? (BrowserHelpers.getHistorySerialCount() ?? 0) : 0;

    // Setup the url strategy (if hash, do nothing since it is the default)
    if (widget.mode == VRouterModes.history) {
      setPathUrlStrategy();
    }

    // Check if this is the first route
    if (_serialCount == 0) {
      // If it is, navigate to initial url if this is not the default one
      if (widget.initialUrl != '/') {
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          pushReplacement(widget.initialUrl);
        });
      }
    }

    // If we are on the web, we listen to any unload event.
    // This allows us to call beforeLeave when the browser or the tab
    // is being closed for example
    if (kIsWeb) {
      BrowserHelpers.onBrowserBeforeUnload.listen((e) => _onBeforeUnload());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleUrlHandler(
      urlToAppState:
          (BuildContext context, RouteInformation routeInformation) async {
        if (routeInformation.location != null && !_ignoreNextBrowserCalls) {
          // Get the new state
          final newState = (kIsWeb)
              ? Map<String, dynamic>.from(jsonDecode(
                  (routeInformation.state as String?) ??
                      (BrowserHelpers.getHistoryState() ?? '{}')))
              : <String, dynamic>{};

          // Get the new serial count
          int? newSerialCount;
          try {
            newSerialCount = newState['serialCount'];
            // ignore: empty_catches
          } on FormatException {}

          // Get the new history state
          final newHistoryState = Map<String, String>.from(
              jsonDecode(newState['historyState'] ?? '{}'));

          // Check if this is the first route
          if (newSerialCount == null || newSerialCount == 0) {
            // If so, check is the url reported by the browser is the same as the initial url
            // We check "routeInformation.location == '/'" to enable deep linking
            if (routeInformation.location == '/' &&
                routeInformation.location != widget.initialUrl) {
              return;
            }
          }

          // Update the app with the new url
          await _updateUrl(
            routeInformation.location!,
            newHistoryState: newHistoryState,
            fromBrowser: true,
            newSerialCount: newSerialCount ?? _serialCount + 1,
          );
        }
        return null;
      },
      appStateToUrl: () {
        return _doReportBackUrlToBrowser
            ? RouteInformation(
                location: url ?? '/',
                state: jsonEncode({
                  'serialCount': _serialCount,
                  'historyState': jsonEncode(historyState),
                }),
              )
            : null;
      },
      child: NotificationListener<VWidgetGuardMessageRoot>(
        onNotification: (VWidgetGuardMessageRoot vWidgetGuardMessageRoot) {
          _vWidgetGuardMessagesRoot.removeWhere((message) =>
              message.vWidgetGuard.key ==
              vWidgetGuardMessageRoot.vWidgetGuard.key);
          _vWidgetGuardMessagesRoot.add(vWidgetGuardMessageRoot);

          return true;
        },
        child: RootVRouterData(
          state: this,
          previousUrl: previousUrl,
          url: url,
          pathParameters: pathParameters,
          historyState: historyState,
          queryParameters: queryParameters,
          child: Builder(
            builder: (context) {
              _rootVRouterContext = context;

              final child = VRouterHelper(
                pages: _vRoute.pages.isNotEmpty
                    ? _vRoute.pages
                    : [
                        MaterialPage(child: Container()),
                      ],
                navigatorKey: _navigatorKey,
                observers: [_heroController],
                backButtonDispatcher: RootBackButtonDispatcher(),
                onPopPage: (_, __) {
                  _pop(
                    _vRoute.vRouteElementNode.getVRouteElementToPop(),
                    pathParameters: pathParameters,
                  );
                  return false;
                },
                onSystemPopPage: () async {
                  await _systemPop(
                    _vRoute.vRouteElementNode.getVRouteElementToPop(),
                    pathParameters: pathParameters,
                  );
                  return true;
                },
              );

              return widget.builder?.call(context, child) ?? child;
            },
          ),
        ),
      ),
      title: widget.title ?? '',
      onGenerateTitle: widget.onGenerateTitle,
      color: widget.color,
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      highContrastTheme: widget.highContrastTheme,
      highContrastDarkTheme: widget.highContrastDarkTheme,
      themeMode: widget.themeMode,
      locale: widget.locale,
      localizationsDelegates: widget.localizationsDelegates,
      localeListResolutionCallback: widget.localeListResolutionCallback,
      localeResolutionCallback: widget.localeResolutionCallback,
      supportedLocales:
          widget.supportedLocales ?? const <Locale>[Locale('en', 'US')],
      debugShowMaterialGrid: widget.debugShowMaterialGrid ?? false,
      showPerformanceOverlay: widget.showPerformanceOverlay ?? false,
      checkerboardRasterCacheImages:
          widget.checkerboardRasterCacheImages ?? false,
      checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers ?? false,
      showSemanticsDebugger: widget.showSemanticsDebugger ?? false,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner ?? true,
      shortcuts: widget.shortcuts,
      actions: widget.actions,
    );
  }

  /// Updates every state variables of [VRouter]
  ///
  /// Note that this does not call setState
  void _updateStateVariables(
    VRoute vRoute,
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) {
    // Update the vRoute
    this._vRoute = vRoute;

    // Update the urls
    previousUrl = url;
    url = newUrl;

    // Update the history state
    this.historyState = historyState;

    // Update the path parameters
    this.pathParameters = vRoute.pathParameters;

    // Update the query parameters
    this.queryParameters = queryParameters;
  }

  /// See [VRouterMethodsHolder.pushNamed]
  void _updateUrlFromName(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
    bool isReplacement = false,
  }) {
    // Encode the path parameters
    pathParameters = pathParameters
        .map((key, value) => MapEntry(key, Uri.encodeComponent(value)));

    // We use VRouteElement.getPathFromName
    String? newPath = widget.getPathFromName(
      name,
      pathParameters: pathParameters,
      parentPath: null,
      remainingPathParameters: pathParameters,
    );

    if (newPath == null) {
      throw Exception(
          'No route correspond to the name $name given the pathParameters $pathParameters');
    }

    // Encode the path parameters
    final encodedPathParameters = pathParameters.map<String, String>(
      (key, value) => MapEntry(key, Uri.encodeComponent(value)),
    );

    // Inject the encoded path parameters into the new path
    newPath = pathToFunction(newPath)(encodedPathParameters);

    // Update the url with the found and completed path
    _updateUrl(newPath,
        queryParameters: queryParameters, isReplacement: isReplacement);
  }

  /// This should be the only way to change a url.
  /// Navigation cycle:
  /// 1. Call beforeLeave in all deactivated [VWidgetGuard]
  /// 2. Call beforeLeave in all deactivated [VRouteElement]
  /// 3. Call beforeLeave in the [VRouter]
  /// 4. Call beforeEnter in the [VRouter]
  /// 5. Call beforeEnter in all initialized [VRouteElement] of the new route
  /// 6. Call beforeUpdate in all reused [VRouteElement]
  ///
  /// ## The history state got in beforeLeave are stored
  /// ## The state is updated
  ///
  /// 7. Call afterEnter in all initialized [VWidgetGuard]
  /// 8. Call afterEnter all initialized [VRouteElement]
  /// 9. Call afterEnter in the [VRouter]
  /// 10. Call afterUpdate in all reused [VWidgetGuard]
  /// 11. Call afterUpdate in all reused [VRouteElement]
  Future<void> _updateUrl(
    String newUrl, {
    Map<String, String> newHistoryState = const {},
    bool fromBrowser = false,
    int? newSerialCount,
    Map<String, String> queryParameters = const {},
    bool isUrlExternal = false,
    bool isReplacement = false,
    bool openNewTab = false,
  }) async {
    assert(!kIsWeb || (!fromBrowser || newSerialCount != null));

    // Reset this to true, new url = new chance to report
    _doReportBackUrlToBrowser = true;

    // This should never happen, if it does this is in error in this package
    // We take care of passing the right parameters depending on the platform
    assert(kIsWeb || isReplacement == false,
        'This does not make sense to replace the route if you are not on the web. Please set isReplacement to false.');

    var newUri = Uri.parse(newUrl);
    final newPath = newUri.path;
    assert(!(newUri.queryParameters.isNotEmpty && queryParameters.isNotEmpty),
        'You used the queryParameters attribute but the url already contained queryParameters. The latter will be overwritten by the argument you gave');
    if (queryParameters.isEmpty) {
      queryParameters = newUri.queryParameters;
    }
    // Decode queryParameters
    queryParameters = queryParameters.map(
      (key, value) => MapEntry(key, Uri.decodeComponent(value)),
    );

    // Add the queryParameters to the url if needed
    if (queryParameters.isNotEmpty) {
      newUri = Uri(path: newPath, queryParameters: queryParameters);
    }

    // Get only the path from the url
    final path = (url != null) ? Uri.parse(url!).path : null;

    late final List<VRouteElement> deactivatedVRouteElements;
    late final List<VRouteElement> reusedVRouteElements;
    late final List<VRouteElement> initializedVRouteElements;
    late final List<VWidgetGuardMessageRoot>
        deactivatedVWidgetGuardsMessagesRoot;
    late final List<VWidgetGuardMessageRoot> reusedVWidgetGuardsMessagesRoot;
    VRoute? newVRoute;
    if (isUrlExternal) {
      newVRoute = null;
      deactivatedVRouteElements = <VRouteElement>[];
      reusedVRouteElements = <VRouteElement>[];
      initializedVRouteElements = <VRouteElement>[];
      deactivatedVWidgetGuardsMessagesRoot = <VWidgetGuardMessageRoot>[];
      reusedVWidgetGuardsMessagesRoot = <VWidgetGuardMessageRoot>[];
    } else {
      // Get the new route
      newVRoute = widget.buildRoute(
        VPathRequestData(
          previousUrl: url,
          uri: newUri,
          historyState: newHistoryState,
          rootVRouterContext: _rootVRouterContext,
        ),
        parentRemainingPath: newPath,
        parentPathParameters: {},
      );

      if (newVRoute == null) {
        throw Exception(
            'No route could be found for the url ${newUri.toString()}');
      }

      // This copy is necessary in order not to modify newVRoute.vRouteElements
      final newVRouteElements =
          List<VRouteElement>.from(newVRoute.vRouteElements);

      deactivatedVRouteElements = <VRouteElement>[];
      reusedVRouteElements = <VRouteElement>[];
      if (_vRoute.vRouteElements.isNotEmpty) {
        for (var vRouteElement in _vRoute.vRouteElements.reversed) {
          try {
            reusedVRouteElements.add(
              newVRouteElements.firstWhere(
                (newVRouteElement) => (newVRouteElement == vRouteElement),
              ),
            );
          } on StateError {
            deactivatedVRouteElements.add(vRouteElement);
          }
        }
      }
      initializedVRouteElements = newVRouteElements
          .where(
            (newVRouteElement) =>
                _vRoute.vRouteElements.indexWhere(
                    (vRouteElement) => vRouteElement == newVRouteElement) ==
                -1,
          )
          .toList();

      // Get deactivated and reused VWidgetGuards
      deactivatedVWidgetGuardsMessagesRoot = _vWidgetGuardMessagesRoot
          .where((vWidgetGuardMessageRoot) => deactivatedVRouteElements
              .contains(vWidgetGuardMessageRoot.associatedVRouteElement))
          .toList();
      reusedVWidgetGuardsMessagesRoot = _vWidgetGuardMessagesRoot
          .where((vWidgetGuardMessageRoot) => reusedVRouteElements
              .contains(vWidgetGuardMessageRoot.associatedVRouteElement))
          .toList();
    }

    Map<String, String> historyStateToSave = {};
    void saveHistoryState(Map<String, String> historyState) {
      historyStateToSave.addAll(historyState);
    }

    // Instantiate VRedirector
    final vRedirector = VRedirector(
      context: _rootVRouterContext,
      from: url,
      to: newUri.toString(),
      previousVRouterData: RootVRouterData(
        child: Container(),
        historyState: historyState,
        pathParameters: _vRoute.pathParameters,
        queryParameters: this.queryParameters,
        state: this,
        url: url,
        previousUrl: previousUrl,
      ),
      newVRouterData: RootVRouterData(
        child: Container(),
        historyState: newHistoryState,
        pathParameters: newVRoute?.pathParameters ?? {},
        queryParameters: queryParameters,
        state: this,
        url: newUri.toString(),
        previousUrl: url,
      ),
    );

    if (url != null) {
      ///   1. Call beforeLeave in all deactivated [VWidgetGuard]
      for (var vWidgetGuardMessageRoot
          in deactivatedVWidgetGuardsMessagesRoot) {
        await vWidgetGuardMessageRoot.vWidgetGuard
            .beforeLeave(vRedirector, saveHistoryState);
        if (!vRedirector._shouldUpdate) {
          await _abortUpdateUrl(
            fromBrowser: fromBrowser,
            serialCount: _serialCount,
            newSerialCount: newSerialCount,
          );

          vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                  .getChildVRouteElementNode(
                      vRouteElement:
                          vWidgetGuardMessageRoot.associatedVRouteElement) ??
              _vRoute.vRouteElementNode);
          return;
        }
      }

      ///   2. Call beforeLeave in all deactivated [VRouteElement]
      for (var vRouteElement in deactivatedVRouteElements) {
        await vRouteElement.beforeLeave(vRedirector, saveHistoryState);
        if (!vRedirector._shouldUpdate) {
          await _abortUpdateUrl(
            fromBrowser: fromBrowser,
            serialCount: _serialCount,
            newSerialCount: newSerialCount,
          );
          vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                  .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
              _vRoute.vRouteElementNode);
          return;
        }
      }

      /// 3. Call beforeLeave in the [VRouter]
      await widget.beforeLeave(vRedirector, saveHistoryState);
      if (!vRedirector._shouldUpdate) {
        await _abortUpdateUrl(
          fromBrowser: fromBrowser,
          serialCount: _serialCount,
          newSerialCount: newSerialCount,
        );
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode);
        return;
      }
    }

    if (!isUrlExternal) {
      /// 4. Call beforeEnter in the [VRouter]
      await widget.beforeEnter(vRedirector);
      if (!vRedirector._shouldUpdate) {
        await _abortUpdateUrl(
          fromBrowser: fromBrowser,
          serialCount: _serialCount,
          newSerialCount: newSerialCount,
        );
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode);
        return;
      }

      /// 5. Call beforeEnter in all initialized [VRouteElement] of the new route
      for (var vRouteElement in initializedVRouteElements) {
        await vRouteElement.beforeEnter(vRedirector);
        if (!vRedirector._shouldUpdate) {
          await _abortUpdateUrl(
            fromBrowser: fromBrowser,
            serialCount: _serialCount,
            newSerialCount: newSerialCount,
          );
          vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                  .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
              _vRoute.vRouteElementNode);
          return;
        }
      }

      /// 6. Call beforeUpdate in all reused [VRouteElement]
      for (var vRouteElement in reusedVRouteElements) {
        await vRouteElement.beforeUpdate(vRedirector);
        if (!vRedirector._shouldUpdate) {
          await _abortUpdateUrl(
            fromBrowser: fromBrowser,
            serialCount: _serialCount,
            newSerialCount: newSerialCount,
          );

          vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                  .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
              _vRoute.vRouteElementNode);
          return;
        }
      }
    }

    final oldSerialCount = _serialCount;

    if (historyStateToSave.isNotEmpty && path != null) {
      if (!kIsWeb) {
        log(
          ' WARNING: Tried to store the state $historyStateToSave while not on the web. State saving/restoration only work on the web.\n'
          'You can safely ignore this message if you just want this functionality on the web.',
          name: 'VRouter',
        );
      } else {
        ///   The historyStates got in beforeLeave are stored   ///
        // If we come from the browser, chances are we already left the page
        // So we need to:
        //    1. Go back to where we were
        //    2. Save the historyState
        //    3. And go back again to the place
        if (kIsWeb && fromBrowser && oldSerialCount != newSerialCount) {
          _ignoreNextBrowserCalls = true;
          BrowserHelpers.browserGo(oldSerialCount - newSerialCount!);
          await BrowserHelpers.onBrowserPopState.firstWhere((element) {
            return BrowserHelpers.getHistorySerialCount() == oldSerialCount;
          });
        }
        BrowserHelpers.replaceHistoryState(jsonEncode({
          'serialCount': oldSerialCount,
          'historyState': jsonEncode(historyStateToSave),
        }));

        if (kIsWeb && fromBrowser && oldSerialCount != newSerialCount) {
          BrowserHelpers.browserGo(newSerialCount! - oldSerialCount);
          await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
              BrowserHelpers.getHistorySerialCount() == newSerialCount);
          _ignoreNextBrowserCalls = false;
        }
      }
    }

    /// Leave if the url is external
    if (isUrlExternal) {
      _ignoreNextBrowserCalls = true;
      await BrowserHelpers.pushExternal(newUri.toString(),
          openNewTab: openNewTab);
      return;
    }

    ///   The state of the VRouter changes            ///
    final oldUrl = url;

    if (isReplacement) {
      _doReportBackUrlToBrowser = false;
      _ignoreNextBrowserCalls = true;
      if (BrowserHelpers.getPathAndQuery(routerMode: widget.mode) !=
          newUri.toString()) {
        BrowserHelpers.pushReplacement(newUri.toString(),
            routerMode: widget.mode);
        if (BrowserHelpers.getPathAndQuery(routerMode: widget.mode) !=
            newUri.toString()) {
          await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
              BrowserHelpers.getPathAndQuery(routerMode: widget.mode) ==
              newUri.toString());
        }
      }
      BrowserHelpers.replaceHistoryState(jsonEncode({
        'serialCount': _serialCount,
        'historyState': jsonEncode(newHistoryState),
      }));
      _ignoreNextBrowserCalls = false;
    } else {
      // If this comes from the browser, newSerialCount is not null
      // If this comes from a user:
      //    - If he/she pushes the same url+historyState, flutter does not create a new history entry so the serialCount remains the same
      //    - Else the serialCount gets increased by 1
      _serialCount = newSerialCount ??
          _serialCount +
              ((newUrl != url || newHistoryState != historyState) ? 1 : 0);
    }
    setState(() {
      _updateStateVariables(
        newVRoute!,
        newUri.toString(),
        historyState: newHistoryState,
        queryParameters: queryParameters,
      );
    });

    // We need to do this after rebuild as completed so that the user can have access
    // to the new state variables
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      /// 7. Call afterEnter in all initialized [VWidgetGuard]
      // This is done automatically by VNotificationGuard

      /// 8. Call afterEnter all initialized [VRouteElement]
      for (var vRouteElement in initializedVRouteElements) {
        vRouteElement.afterEnter(
          _rootVRouterContext,
          // TODO: Change this to local context? This might imply that we need a global key which is not ideal
          oldUrl,
          newUri.toString(),
        );
      }

      /// 9. Call afterEnter in the [VRouter]
      widget.afterEnter(_rootVRouterContext, oldUrl, newUri.toString());

      /// 10. Call afterUpdate in all reused [VWidgetGuard]
      for (var vWidgetGuardMessageRoot in reusedVWidgetGuardsMessagesRoot) {
        vWidgetGuardMessageRoot.vWidgetGuard.afterUpdate(
          vWidgetGuardMessageRoot.localContext,
          oldUrl,
          newUri.toString(),
        );
      }

      /// 11. Call afterUpdate in all reused [VRouteElement]
      for (var vRouteElement in reusedVRouteElements) {
        vRouteElement.afterUpdate(
          _rootVRouterContext,
          // TODO: Change this to local context? This might imply that we need a global key which is not ideal
          oldUrl,
          newUri.toString(),
        );
      }
    });
  }

  /// This function is used in [updateUrl] when the update should be canceled
  /// This happens and vRedirector is used to stop the navigation
  ///
  /// On mobile nothing happens
  /// On the web, if the browser already navigated away, we have to navigate back to where we were
  ///
  /// Note that this should be called before setState, otherwise it is useless and cannot prevent a state spread
  ///
  /// newSerialCount should not be null if the updateUrl came from the Browser
  Future<void> _abortUpdateUrl({
    required bool fromBrowser,
    required int serialCount,
    required int? newSerialCount,
  }) async {
    // If the url change comes from the browser, chances are the url is already changed
    // So we have to navigate back to the old url (stored in _url)
    // Note: in future version it would be better to delete the last url of the browser
    //        but it is not yet possible
    if (kIsWeb &&
        fromBrowser &&
        (BrowserHelpers.getHistorySerialCount() ?? 0) != serialCount) {
      _ignoreNextBrowserCalls = true;
      BrowserHelpers.browserGo(serialCount - newSerialCount!);
      await BrowserHelpers.onBrowserPopState.firstWhere((element) {
        return BrowserHelpers.getHistorySerialCount() == serialCount;
      });
      _ignoreNextBrowserCalls = false;
    }
    return;
  }

  /// Performs a systemPop cycle:
  ///   1. Call onPop in all active [VWidgetGuards]
  ///   2. Call onPop in all [VRouteElement]
  ///   3. Call onPop of VRouter
  ///   4. Update the url to the one found in [_defaultPop]
  Future<void> _pop(
    VRouteElement elementToPop, {
    VRedirector? vRedirector,
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) async {
    assert(url != null);

    // Instantiate VRedirector if null
    // It might be not null if called from systemPop
    vRedirector ??= _defaultPop(
      elementToPop,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      newHistoryState: newHistoryState,
    );

    /// 1. Call onPop in all active [VWidgetGuards]
    for (var vWidgetGuardMessageRoot in _vWidgetGuardMessagesRoot) {
      await vWidgetGuardMessageRoot.vWidgetGuard.onPop(vRedirector);
      if (!vRedirector.shouldUpdate) {vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
          .getChildVRouteElementNode(vRouteElement: vWidgetGuardMessageRoot.associatedVRouteElement) ??
          _vRoute.vRouteElementNode);
        return;
      }
    }

    /// 2. Call onPop in all [VRouteElement]
    /// 3. Call onPop of VRouter
    for (var vRouteElement in _vRoute.vRouteElements.reversed) {
      await vRouteElement.onPop(vRedirector);
      if (!vRedirector.shouldUpdate) {
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
            .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
            _vRoute.vRouteElementNode);
        return;
      }
    }

    /// 4. Update the url to the one found in [_defaultPop]
    if (vRedirector.newVRouterData != null) {
      _updateUrl(vRedirector.to!,
          queryParameters: queryParameters, newHistoryState: newHistoryState);
    } else if (!kIsWeb) {
      // If we didn't find a url to go to, we are at the start of the stack
      // so we close the app on mobile
      MoveToBackground.moveTaskToBack();
    }
  }

  /// Performs a systemPop cycle:
  /// 1. Call onSystemPop in all active [VWidgetGuards] if implemented, else onPop
  /// 2. Call onSystemPop in all [VRouteElement] if implemented, else onPop
  /// 3. Call onSystemPop of VRouter if implemented, else onPop
  /// 4. Update the url to the one found in [_defaultPop]
  Future<void> _systemPop(
    VRouteElement itemToPop, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) async {
    assert(url != null);

    // Instantiate VRedirector
    final vRedirector = _defaultPop(
      itemToPop,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      newHistoryState: newHistoryState,
    );

    /// 1. Call onSystemPop in all active [VWidgetGuards] if implemented, else onPop
    for (var vWidgetGuardMessageRoot in _vWidgetGuardMessagesRoot) {
      if (vWidgetGuardMessageRoot.vWidgetGuard.onSystemPop !=
          VRouteElement._voidOnSystemPop) {
        await vWidgetGuardMessageRoot.vWidgetGuard.onSystemPop(vRedirector);
      } else {
        await vWidgetGuardMessageRoot.vWidgetGuard.onPop(vRedirector);
      }
      if (!vRedirector.shouldUpdate) {
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
            .getChildVRouteElementNode(vRouteElement: vWidgetGuardMessageRoot.associatedVRouteElement) ??
            _vRoute.vRouteElementNode);
        return;
      }
    }

    /// 2. Call onSystemPop in all [VRouteElement] if implemented, else onPop
    /// 3. Call onSystemPop of VRouter if implemented, else onPop
    for (var vRouteElement in _vRoute.vRouteElements.reversed) {
      if (vRouteElement.onSystemPop != VRouteElement._voidOnSystemPop) {
        await vRouteElement.onSystemPop(vRedirector);
      } else {
        await vRouteElement.onPop(vRedirector);
      }
      if (!vRedirector.shouldUpdate) {
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
            .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
            _vRoute.vRouteElementNode);
        return;
      }
    }

    /// 4. Update the url to the one found in [_defaultPop]
    if (vRedirector.newVRouterData != null) {
      _updateUrl(vRedirector.to!,
          queryParameters: queryParameters, newHistoryState: newHistoryState);
    } else if (!kIsWeb) {
      // If we didn't find a url to go to, we are at the start of the stack
      // so we close the app on mobile
      MoveToBackground.moveTaskToBack();
    }
  }

  /// Uses [VRouteElement.getPathFromPop] to determine the new path after popping [elementToPop]
  ///
  /// See:
  ///   * [VWidgetGuard.onPop] to override this behaviour locally
  ///   * [VRouteElement.onPop] to override this behaviour on a on a route level
  ///   * [VRouter.onPop] to override this behaviour on a global level
  ///   * [VWidgetGuard.onSystemPop] to override this behaviour locally
  ///                               when the call comes from the system
  ///   * [VRouteElement.onSystemPop] to override this behaviour on a route level
  ///                               when the call comes from the system
  ///   * [VRouter.onSystemPop] to override this behaviour on a global level
  ///                               when the call comes from the system
  VRedirector _defaultPop(
    VRouteElement elementToPop, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) {
    assert(url != null);
    // Encode the path parameters
    pathParameters = pathParameters
        .map((key, value) => MapEntry(key, Uri.encodeComponent(value)));

    // This url will be not null if we find a route to go to
    String? newUrl;

    // We don't use widget.getPathFromPop because widget.routes might have changed with a setState
    final newPath = _vRoute.vRouteElementNode.vRouteElement
        .getPathFromPop(elementToPop,
            pathParameters: pathParameters, parentPath: null)
        ?.path;

    late final RootVRouterData? newVRouterData;
    // If newPath is empty then the VRouteElement to pop is VRouter
    if (newPath != null && newPath.isNotEmpty) {
      // Integrate the given query parameters
      newUrl = Uri.tryParse(newPath)
          ?.replace(
              queryParameters:
                  (queryParameters.isNotEmpty) ? queryParameters : null)
          .toString();

      newVRouterData = RootVRouterData(
        child: Container(),
        historyState: newHistoryState,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        url: newUrl,
        previousUrl: url,
        state: this,
      );
    } else {
      newVRouterData = null;
    }

    return VRedirector(
      context: _rootVRouterContext,
      from: url,
      to: newUrl,
      previousVRouterData: RootVRouterData(
        child: Container(),
        historyState: historyState,
        pathParameters: _vRoute.pathParameters,
        queryParameters: queryParameters,
        state: this,
        previousUrl: previousUrl,
        url: url,
      ),
      newVRouterData: newVRouterData,
    );
  }

  /// This replaces the current history state of [VRouter] with given one
  void replaceHistoryState(Map<String, String> newHistoryState) {
    pushReplacement((url != null) ? Uri.parse(url!).path : '/',
        historyState: newHistoryState);
  }

  /// WEB ONLY
  /// Save the state if needed before the app gets unloaded
  /// Mind that this happens when the user enter a url manually in the
  /// browser so we can't prevent him from leaving the page
  void _onBeforeUnload() async {
    if (url == null) return;

    Map<String, String> historyStateToSave = {};
    void saveHistoryState(Map<String, String> historyState) {
      historyStateToSave.addAll(historyState);
    }

    // Instantiate VRedirector
    final vRedirector = VRedirector(
      context: _rootVRouterContext,
      from: url,
      to: null,
      previousVRouterData: RootVRouterData(
        child: Container(),
        historyState: historyState,
        pathParameters: _vRoute.pathParameters,
        queryParameters: this.queryParameters,
        state: this,
        url: url,
        previousUrl: previousUrl,
      ),
      newVRouterData: null,
    );

    ///   1. Call beforeLeave in all deactivated [VWidgetGuard]
    for (var vWidgetGuardMessageRoot in _vWidgetGuardMessagesRoot) {
      await vWidgetGuardMessageRoot.vWidgetGuard
          .beforeLeave(vRedirector, saveHistoryState);
    }

    ///   2. Call beforeLeave in all deactivated [VRouteElement] and [VRouter]
    for (var vRouteElement in _vRoute.vRouteElements.reversed) {
      await vRouteElement.beforeLeave(vRedirector, saveHistoryState);
    }

    if (historyStateToSave.isNotEmpty) {
      ///   The historyStates got in beforeLeave are stored   ///
      BrowserHelpers.replaceHistoryState(jsonEncode({
        'serialCount': _serialCount,
        'historyState': jsonEncode(historyStateToSave),
      }));
    }
  }

  /// Starts a pop cycle
  ///
  /// Pop cycle:
  ///   1. onPop is called in all [VNavigationGuard]s
  ///   2. onPop is called in all [VRouteElement]s of the current route
  ///   3. onPop is called in [VRouter]
  ///
  /// In any of the above steps, we can use [vRedirector] if you want to redirect or
  /// stop the navigation
  Future<void> pop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) async {
    _pop(
      _vRoute.vRouteElementNode.getVRouteElementToPop(),
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      newHistoryState: newHistoryState,
    );
  }

  /// Starts a systemPop cycle
  ///
  /// systemPop cycle:
  ///   1. onSystemPop (or onPop if not implemented) is called in all VNavigationGuards
  ///   2. onSystemPop (or onPop if not implemented) is called in the nested-most VRouteElement of the current route
  ///   3. onSystemPop (or onPop if not implemented) is called in VRouter
  ///
  /// In any of the above steps, we can use a [VRedirector] if you want to redirect or
  /// stop the navigation
  Future<void> systemPop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) async {
    _systemPop(
      _vRoute.vRouteElementNode.getVRouteElementToPop(),
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      newHistoryState: newHistoryState,
    );
  }

  /// Pushes the new route of the given url on top of the current one
  /// A path can be of one of two forms:
  ///   * stating with '/', in which case we just navigate
  ///     to the given path
  ///   * not starting with '/', in which case we append the
  ///     current path to the given one
  ///
  /// We can also specify queryParameters, either by directly
  /// putting them is the url or by providing a Map using [queryParameters]
  ///
  /// We can also put a state to the next route, this state will
  /// be a router state (this is the only kind of state that we can
  /// push) accessible with VRouter.of(context).historyState
  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) {
    if (!newUrl.startsWith('/')) {
      if (url == null) {
        throw Exception(
            "The current url is null but you are trying to access a path which does not start with '/'.");
      }
      final currentPath = Uri.parse(url!).path;
      newUrl = currentPath + '/$newUrl';
    }

    _updateUrl(
      newUrl,
      queryParameters: queryParameters,
      newHistoryState: historyState,
    );
  }

  /// Updates the url given a [VRouteElement] name
  ///
  /// We can also specify path parameters to inject into the new path
  ///
  /// We can also specify queryParameters, either by directly
  /// putting them is the url or by providing a Map using [queryParameters]
  ///
  /// We can also put a state to the next route, this state will
  /// be a router state (this is the only kind of state that we can
  /// push) accessible with VRouter.of(context).historyState
  ///
  /// After finding the url and taking charge of the path parameters,
  /// it updates the url
  ///
  /// To specify a name, see [VRouteElement.name]
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) {
    _updateUrlFromName(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newHistoryState: historyState);
  }

  /// Replace the current one by the new route corresponding to the given url
  /// The difference with [push] is that this overwrites the current browser history entry
  /// If you are on mobile, this is the same as push
  /// Path can be of one of two forms:
  ///   * stating with '/', in which case we just navigate
  ///     to the given path
  ///   * not starting with '/', in which case we append the
  ///     current path to the given one
  ///
  /// We can also specify queryParameters, either by directly
  /// putting them is the url or by providing a Map using [queryParameters]
  ///
  /// We can also put a state to the next route, this state will
  /// be a router state (this is the only kind of state that we can
  /// push) accessible with VRouter.of(context).historyState
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) {
    // If not on the web, this is the same as push
    if (!kIsWeb) {
      return push(newUrl,
          queryParameters: queryParameters, historyState: historyState);
    }

    if (!newUrl.startsWith('/')) {
      if (url == null) {
        throw Exception(
            "The current url is null but you are trying to access a path which does not start with'/'.");
      }
      final currentPath = Uri.parse(url!).path;
      newUrl = currentPath + '/$newUrl';
    }

    // Update the url, setting isReplacement to true
    _updateUrl(
      newUrl,
      queryParameters: queryParameters,
      newHistoryState: historyState,
      isReplacement: true,
    );
  }

  /// Replace the url given a [VRouteElement] name
  /// The difference with [pushNamed] is that this overwrites the current browser history entry
  ///
  /// We can also specify path parameters to inject into the new path
  ///
  /// We can also specify queryParameters, either by directly
  /// putting them is the url or by providing a Map using [queryParameters]
  ///
  /// We can also put a state to the next route, this state will
  /// be a router state (this is the only kind of state that we can
  /// push) accessible with VRouter.of(context).historyState
  ///
  /// After finding the url and taking charge of the path parameters
  /// it updates the url
  ///
  /// To specify a name, see [VRouteElementWithPath.name]
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) {
    _updateUrlFromName(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newHistoryState: historyState,
        isReplacement: true);
  }

  /// Goes to an url which is not in the app
  ///
  /// On the web, you can set [openNewTab] to true to open this url
  /// in a new tab
  void pushExternal(String newUrl, {bool openNewTab = false}) =>
      _updateUrl(newUrl, isUrlExternal: true, openNewTab: openNewTab);
}
