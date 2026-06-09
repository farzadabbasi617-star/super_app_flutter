import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final double walletBalance;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.walletBalance,
  });

  UserProfile copyWith({double? walletBalance}) {
    return UserProfile(
      uid: uid,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }

  @override
  List<Object?> get props => [uid, fullName, email, phoneNumber, avatarUrl, walletBalance];
}
