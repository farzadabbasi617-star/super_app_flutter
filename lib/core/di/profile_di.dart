import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_wallet_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import 'service_locator.dart';

Future<void> initProfileAndPayment() async {
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  // Register UpdateWalletUseCase
  sl.registerLazySingleton(() => UpdateWalletUseCase(sl()));
  sl.registerFactory(() => ProfileBloc(getProfile: sl(), updateWallet: sl()));
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl()),
  );
}
