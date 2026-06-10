import 'package:get_it/get_it.dart';

// Modular DI imports
import 'core_di.dart';
import 'auth_di.dart';
import 'map_di.dart';
import 'services_di.dart';
import 'marketplace_di.dart';
import 'profile_di.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize modules in order of dependency
  await initCore();
  await initAuth();
  await initMap();
  await initServices();
  await initMarketplace();
  await initProfileAndPayment();
}
