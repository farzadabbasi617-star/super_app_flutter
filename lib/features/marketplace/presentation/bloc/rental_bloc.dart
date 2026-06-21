import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/book_equipment_usecase.dart';

abstract class RentalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookRentalRequested extends RentalEvent {
  final String productId;
  final DateTime start;
  final DateTime end;
  BookRentalRequested(this.productId, this.start, this.end);
  @override
  List<Object?> get props => [productId, start, end];
}

abstract class RentalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RentalInitial extends RentalState {}

class RentalBookingLoading extends RentalState {}

class RentalBookingSuccess extends RentalState {}

class RentalBookingFailure extends RentalState {
  final String error;
  RentalBookingFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class RentalBloc extends Bloc<RentalEvent, RentalState> {
  final BookEquipmentUseCase bookEquipment;

  RentalBloc({required this.bookEquipment}) : super(RentalInitial()) {
    on<BookRentalRequested>((event, emit) async {
      emit(RentalBookingLoading());
      final result = await bookEquipment.execute(
        productId: event.productId,
        startDate: event.start,
        endDate: event.end,
      );
      result.fold(
        (failure) => emit(RentalBookingFailure(failure.message)),
        (success) => emit(RentalBookingSuccess()),
      );
    });
  }
}
