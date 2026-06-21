import 'package:dartz/dartz.dart';
import '../entities/transaction.dart';
import 'package:super_app_flutter/core/error/failures.dart';

abstract class PaymentRepository {
  Future<Either<Failure, Transaction>> processPayment(
    double amount,
    String description,
  );
  Future<Either<Failure, List<Transaction>>> getTransactionHistory();
}
