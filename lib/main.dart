import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_app/config/di.dart';
import 'config/app_theme.dart';
import 'features/property/data/repository/analytics_service.dart';
import 'features/property/domain/entities/property.dart';
import 'features/property/presentation/bloc/property_bloc.dart';
import 'features/property/presentation/pages/analytics_page.dart';
import 'features/property/presentation/pages/property_details_page.dart';
import 'features/property/presentation/pages/property_list_page.dart';
import 'features/theme/presentation/bloc/theme_bloc.dart';
import 'features/theme/presentation/bloc/theme_state.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await setupDependencyInjector();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    final messaging = FirebaseMessaging.instance;


    await messaging.requestPermission();


    String? token = await messaging.getToken();
    print("FCM TOKEN = $token");


    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNavigation(message);
      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen(_handleNavigation);
  }

  void _handleNavigation(RemoteMessage message) {
    if (message.data.containsKey('route')) {
      String route = message.data['route'];
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AnalyticsService>(
          create: (_) => getIt<AnalyticsService>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (context) => getIt<ThemeBloc>(),
          ),
          BlocProvider<PropertyBloc>(
            create: (context) => getIt<PropertyBloc>(),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Property Listing App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const PropertyListScreen(),
              routes: {
                '/analytics': (context) => const AnalyticsScreen(),
                '/property-detail': (context) {
                  final property = ModalRoute.of(context)?.settings.arguments as Property;
                  return PropertyDetailsPage(property: property);
                },
              },
            );
          },
        ),
      ),
    );
  }
}
