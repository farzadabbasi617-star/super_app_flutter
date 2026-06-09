import 'package:equatable/equatable.dart';

enum TransactionType { payment, refund, topup }

class Transaction extends Equatable {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final TransactionType type;

  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
  });

  @override
  List<Object?> get props => [id, amount, date, description, type];
}
