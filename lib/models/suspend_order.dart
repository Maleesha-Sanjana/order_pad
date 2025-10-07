class SuspendOrder {
  final int? id;
  final String productCode;
  final String productDescription;
  final String unit;
  final double? packSize;
  final double? freeQty;
  final double costPrice;
  final double unitPrice;
  final double wholeSalePrice;
  final double qty;
  final double? discPer;
  final double? discAmount;
  final double amount;
  final String? iid;
  final String? locaCode;
  final String? batchNo;
  final String? stockLoca;
  final double? tax;
  final int? rowIdx;
  final String? serialNo;
  final int? warrantyPeriod;
  final int? periodDays;
  final DateTime? expiryDate;
  final String? receiptNo;
  final String salesMan;
  final String? customer;
  final String table;
  final String? chair;
  final bool? kotPrint;

  const SuspendOrder({
    this.id,
    required this.productCode,
    required this.productDescription,
    required this.unit,
    this.packSize,
    this.freeQty,
    required this.costPrice,
    required this.unitPrice,
    required this.wholeSalePrice,
    required this.qty,
    this.discPer,
    this.discAmount,
    required this.amount,
    this.iid,
    this.locaCode,
    this.batchNo,
    this.stockLoca,
    this.tax,
    this.rowIdx,
    this.serialNo,
    this.warrantyPeriod,
    this.periodDays,
    this.expiryDate,
    this.receiptNo,
    required this.salesMan,
    this.customer,
    required this.table,
    this.chair,
    this.kotPrint,
  });

  factory SuspendOrder.fromJson(Map<String, dynamic> json) {
    return SuspendOrder(
      id: json['id'] as int?,
      productCode: json['ProductCode']?.toString() ?? '',
      productDescription: json['ProductDescription']?.toString() ?? '',
      unit: json['Unit']?.toString() ?? '',
      packSize: (json['PackSize'] as num?)?.toDouble(),
      freeQty: (json['FreeQty'] as num?)?.toDouble(),
      costPrice: (json['CostPrice'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['UnitPrice'] as num?)?.toDouble() ?? 0.0,
      wholeSalePrice: (json['WholeSalePrice'] as num?)?.toDouble() ?? 0.0,
      qty: (json['Qty'] as num?)?.toDouble() ?? 0.0,
      discPer: (json['DiscPer'] as num?)?.toDouble(),
      discAmount: (json['DiscAmount'] as num?)?.toDouble(),
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      iid: json['Iid']?.toString(),
      locaCode: json['LocaCode']?.toString(),
      batchNo: json['BatchNo']?.toString(),
      stockLoca: json['StockLoca']?.toString(),
      tax: (json['Tax'] as num?)?.toDouble(),
      rowIdx: json['RowIdx'] as int?,
      serialNo: json['SerialNo']?.toString(),
      warrantyPeriod: json['WarrantyPeriod'] as int?,
      periodDays: json['PeriodDays'] as int?,
      expiryDate: json['ExpiryDate'] != null
          ? DateTime.tryParse(json['ExpiryDate'].toString())
          : null,
      receiptNo: json['ReceiptNo']?.toString(),
      salesMan: json['SalesMan']?.toString() ?? '',
      customer: json['Customer']?.toString(),
      table: json['Table']?.toString() ?? '',
      chair: json['Chair']?.toString(),
      kotPrint: json['KotPrint'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'ProductCode': productCode,
      'ProductDescription': productDescription,
      'Unit': unit,
      'PackSize': packSize,
      'FreeQty': freeQty,
      'CostPrice': costPrice,
      'UnitPrice': unitPrice,
      'WholeSalePrice': wholeSalePrice,
      'Qty': qty,
      'DiscPer': discPer,
      'DiscAmount': discAmount,
      'Amount': amount,
      'Iid': iid,
      'LocaCode': locaCode,
      'BatchNo': batchNo,
      'StockLoca': stockLoca,
      'Tax': tax,
      'RowIdx': rowIdx,
      'SerialNo': serialNo,
      'WarrantyPeriod': warrantyPeriod,
      'PeriodDays': periodDays,
      'ExpiryDate': expiryDate?.toIso8601String(),
      'ReceiptNo': receiptNo,
      'SalesMan': salesMan,
      'Customer': customer,
      'Table': table,
      'Chair': chair,
      'KotPrint': kotPrint,
    };

    // Include id if it's provided
    if (id != null) {
      json['id'] = id;
    }

    return json;
  }

  SuspendOrder copyWith({
    int? id,
    String? productCode,
    String? productDescription,
    String? unit,
    double? packSize,
    double? freeQty,
    double? costPrice,
    double? unitPrice,
    double? wholeSalePrice,
    double? qty,
    double? discPer,
    double? discAmount,
    double? amount,
    String? iid,
    String? locaCode,
    String? batchNo,
    String? stockLoca,
    double? tax,
    int? rowIdx,
    String? serialNo,
    int? warrantyPeriod,
    int? periodDays,
    DateTime? expiryDate,
    String? receiptNo,
    String? salesMan,
    String? customer,
    String? table,
    String? chair,
    bool? kotPrint,
  }) {
    return SuspendOrder(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      productDescription: productDescription ?? this.productDescription,
      unit: unit ?? this.unit,
      packSize: packSize ?? this.packSize,
      freeQty: freeQty ?? this.freeQty,
      costPrice: costPrice ?? this.costPrice,
      unitPrice: unitPrice ?? this.unitPrice,
      wholeSalePrice: wholeSalePrice ?? this.wholeSalePrice,
      qty: qty ?? this.qty,
      discPer: discPer ?? this.discPer,
      discAmount: discAmount ?? this.discAmount,
      amount: amount ?? this.amount,
      iid: iid ?? this.iid,
      locaCode: locaCode ?? this.locaCode,
      batchNo: batchNo ?? this.batchNo,
      stockLoca: stockLoca ?? this.stockLoca,
      tax: tax ?? this.tax,
      rowIdx: rowIdx ?? this.rowIdx,
      serialNo: serialNo ?? this.serialNo,
      warrantyPeriod: warrantyPeriod ?? this.warrantyPeriod,
      periodDays: periodDays ?? this.periodDays,
      expiryDate: expiryDate ?? this.expiryDate,
      receiptNo: receiptNo ?? this.receiptNo,
      salesMan: salesMan ?? this.salesMan,
      customer: customer ?? this.customer,
      table: table ?? this.table,
      chair: chair ?? this.chair,
      kotPrint: kotPrint ?? this.kotPrint,
    );
  }
}
