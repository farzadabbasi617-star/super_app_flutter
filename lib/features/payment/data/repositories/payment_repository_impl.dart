import '../../domain/repositories/payment_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../../core/error/failures.dart';
import 'package:dio/dio.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final Dio dio;
  PaymentRepositoryImpl(this.dio);

  @override
  Future<Either<Failure, Transaction>> processPayment(double amount, String description) async {
    await Future.delayed(const Duration(seconds: 2));
    return Either.right(Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      date: DateTime.now(),
      description: description,
      status: TransactionStatus.completed,
      type: TransactionType.debit,
    ));
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionHistory() async {
    return Either.right([
      const Transaction(id: 't1', amount: 100.0, date: DateTime(2026, 6, 1), description: 'Wallet Topup', status: TransactionStatus.completed, type: TransactionType.credit),
      const Transaction(id: 't2', amount: 50.0, date: DateTime(2026, 6, 2), description: 'Tool Rental', status: TransactionStatus.completed, type: TransactionType.debit),
    ]);
  }
}
