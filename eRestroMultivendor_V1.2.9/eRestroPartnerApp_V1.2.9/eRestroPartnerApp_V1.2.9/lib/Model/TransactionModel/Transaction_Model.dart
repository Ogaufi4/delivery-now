import '../../Helper/string.dart';

class TransactionModel {
  String? id,
      transactionType,
      orderId,
      userId,
      type,
      txnId,
      payuTxnId,
      amount,
      status,
      currencyCode,
      payerEmail,
      message,
      transactionDate,
      dateCreated;

  TransactionModel(
      {this.id,
      this.transactionType,
      this.orderId,
      this.type,
      this.userId,
      this.txnId,
      this.payuTxnId,
      this.amount,
      this.status,
      this.currencyCode,
      this.payerEmail,
      this.message,
      this.transactionDate,
      this.dateCreated});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json[Id],
      transactionType: json[TransactionType],
      userId: json[UserId],
      orderId: json[ORDER_ID],
      type: json[Type],
      txnId: json[TxnTd],
      payuTxnId: json[PayuTxnId],
      amount: json[Amount],
      status: json[STATUS],
      currencyCode: json[CurrencyCode],
      payerEmail: json[PayerEmail],
      message: json[Message],
      transactionDate: json[TransactionDate],
      dateCreated: json[DateCreated],
    );
  }
}
