import 'package:equatable/equatable.dart';
import '../../domain/entities/shop.dart';

abstract class MapState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}
class MapLoading extends MapState {}
class MapLoaded extends MapState {
  final List<Shop> shops;
  MapLoaded(this.shops);
  @override
  List<Object?> get props => [shops];
}
class MapFailure extends MapState {
  final String error;
  MapFailure(this.error);
  @override
  List<Object?> get props => [error];
}
