import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final double walletBalance;
  final List<String> interests;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.walletBalance,
    this.interests = const [],
  });

  UserProfile copyWith({double? walletBalance, String? fullName}) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      walletBalance: walletBalance ?? this.walletBalance,
      interests: interests,
    );
  }

  @override
  List<Object?> get props => [uid, fullName, email, phoneNumber, avatarUrl, walletBalance, interests];
}
