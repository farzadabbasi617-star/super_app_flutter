import 'package:equatable/equatable.dart';

enum TransactionStatus { pending, completed, failed, refunded }

enum TransactionType { credit, debit }

class Transaction extends Equatable {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final TransactionStatus status;
  final TransactionType type;

  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.status,
    required this.type,
  });

  @override
  List<Object?> get props => [id, amount, date, description, status, type];
}
