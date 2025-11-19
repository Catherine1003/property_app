import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/property/data/datasource/property_remote_datasource.dart';
import '../features/property/data/repository/analytics_service.dart';
import '../features/property/data/repository/property_repository_impl.dart';
import '../features/property/presentation/bloc/property_bloc.dart';
import '../features/theme/presentation/bloc/theme_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjector() async {

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  final dio = Dio();
  getIt.registerSingleton<Dio>(dio);

  getIt.registerSingleton<PropertyRemoteDatasource>(
    PropertyRemoteDatasource(getIt<Dio>()),
  );

  getIt.registerSingleton<AnalyticsService>(
    AnalyticsService(getIt<SharedPreferences>()),
  );

  getIt.registerSingleton<PropertyRepositoryImpl>(
    PropertyRepositoryImpl(
      apiService: getIt<PropertyRemoteDatasource>(),
      analyticsService: getIt<AnalyticsService>(),
    ),
  );

  getIt.registerSingleton<ThemeBloc>(
    ThemeBloc(prefs: getIt<SharedPreferences>()),
  );

  getIt.registerSingleton<PropertyBloc>(
    PropertyBloc(repository: getIt<PropertyRepositoryImpl>()),
  );
}