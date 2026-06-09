import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<LoadProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await profileRepository.getProfile();
      if (result.isRight) {
        emit(ProfileLoaded(result.right));
      } else {
        emit(ProfileFailure((result.left as dynamic).message));
      }
    });

    on<UpdateBalanceRequested>((event, emit) async {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        final result = await profileRepository.updateWalletBalance(event.amount);
        if (result.isRight) {
          emit(ProfileLoaded(currentState.profile.copyWith(walletBalance: result.right)));
        }
      }
    });
  }
}
