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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjector();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
