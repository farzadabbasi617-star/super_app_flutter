import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_wallet_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfile;
  final UpdateWalletUseCase updateWallet;

  ProfileBloc({required this.getProfile, required this.updateWallet}) : super(ProfileInitial()) {
    on<LoadProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await getProfile.execute();
      result.fold(
        (failure) => emit(ProfileFailure(failure.message)),
        (profile) => emit(ProfileLoaded(profile)),
      );
    });

    on<UpdateBalanceRequested>((event, emit) async {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        final result = await updateWallet.execute(event.amount);
        result.fold(
          (failure) => emit(ProfileFailure(failure.message)),
          (newBalance) => emit(ProfileLoaded(currentState.profile.copyWith(walletBalance: newBalance))),
        );
      }
    });
  }
}
