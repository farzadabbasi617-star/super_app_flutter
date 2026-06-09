import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  // sl.registerLazySingleton<NetworkClient>(() => NetworkClient());

  // Features - Auth
  // sl.registerLazySingleton(() => AuthRepositoryImpl());
  // sl.registerFactory(() => AuthBloc(authRepository: sl()));
  
  print("Service Locator Initialized");
}
