class FoodItem {
  final int idx;
  final String productCode;
  final String? productName;
  final String? otherLanguage;
  final String? eanCode;
  final String? departmentCode;
  final String? subDepartmentCode;
  final String? categoryCode;
  final String? subCategoryCode;
  final String? brandCode;
  final String? groupCode;
  final String? supplierCode;
  final String? manufacturerCode;
  final String? colourCode;
  final String? sizeCode;
  final String? partNo;
  final double? costPrice;
  final String? purchasingUnit;
  final int? purchasingPackSize;
  final double? margin;
  final String? costCode;
  final double? unitPrice;
  final String? sellingUnit;
  final int? sellingPackSize;
  final double? wholeSalePrice;
  final double? minimumPrice;
  final double? maximumPrice;
  final double? fixedDiscount;
  final double? maxDiscount;
  final double? taxPrice;
  final double? reOrderQty;
  final int? reOrderPeriod;
  final double? reOrderLevel;
  final String? ledgertCode;
  final bool? promotional;
  final bool? rowmaterial;
  final bool? freeIssue;
  final bool? lockReorder;
  final bool? lockProduct;
  final bool? taxItem;
  final bool? bundled;
  final bool? warranty;
  final bool? service;
  final double? lastPurchasePrice;
  final double? avgCostPrice;
  final bool? serialTrack;
  final bool? serialTrackInvoice;
  final bool? serailPick;
  final bool? warrantyTrackInvoice;
  final bool? warrantyPick;
  final int? warrantyPeriod;
  final bool? miscellaneous;
  final bool? manufactured;
  final bool? batch;
  final bool? expiry;
  final bool? update;
  final DateTime? createdDate;
  final String? createdUser;
  final DateTime? editedDate;
  final String? editedUser;

  const FoodItem({
    required this.idx,
    required this.productCode,
    this.productName,
    this.otherLanguage,
    this.eanCode,
    this.departmentCode,
    this.subDepartmentCode,
    this.categoryCode,
    this.subCategoryCode,
    this.brandCode,
    this.groupCode,
    this.supplierCode,
    this.manufacturerCode,
    this.colourCode,
    this.sizeCode,
    this.partNo,
    this.costPrice,
    this.purchasingUnit,
    this.purchasingPackSize,
    this.margin,
    this.costCode,
    this.unitPrice,
    this.sellingUnit,
    this.sellingPackSize,
    this.wholeSalePrice,
    this.minimumPrice,
    this.maximumPrice,
    this.fixedDiscount,
    this.maxDiscount,
    this.taxPrice,
    this.reOrderQty,
    this.reOrderPeriod,
    this.reOrderLevel,
    this.ledgertCode,
    this.promotional,
    this.rowmaterial,
    this.freeIssue,
    this.lockReorder,
    this.lockProduct,
    this.taxItem,
    this.bundled,
    this.warranty,
    this.service,
    this.lastPurchasePrice,
    this.avgCostPrice,
    this.serialTrack,
    this.serialTrackInvoice,
    this.serailPick,
    this.warrantyTrackInvoice,
    this.warrantyPick,
    this.warrantyPeriod,
    this.miscellaneous,
    this.manufactured,
    this.batch,
    this.expiry,
    this.update,
    this.createdDate,
    this.createdUser,
    this.editedDate,
    this.editedUser,
  });

  // Helper getters for compatibility
  String get id => productCode;
  String get name => productName ?? 'Unknown Product';
  String? get description => otherLanguage;
  double get price => unitPrice ?? 0.0;
  String? get categoryId => departmentCode;
  String? get subCategoryId => subDepartmentCode;
  bool get isAvailable => !(lockProduct == true);
  String? get imageUrl => null; // ProductImage is image type, not URL

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse double values
    double? safeParseDouble(dynamic value) {
      if (value == null || value.toString() == 'NULL') return null;
      return double.tryParse(value.toString());
    }

    // Helper function to safely parse int values
    int? safeParseInt(dynamic value) {
      if (value == null || value.toString() == 'NULL') return null;
      return int.tryParse(value.toString());
    }

    // Helper function to safely parse bool values
    bool? safeParseBool(dynamic value) {
      if (value == null || value.toString() == 'NULL') return null;
      return value.toString() == '1';
    }

    // Helper function to safely parse DateTime values
    DateTime? safeParseDateTime(dynamic value) {
      if (value == null || value.toString() == 'NULL') return null;
      return DateTime.tryParse(value.toString());
    }

    return FoodItem(
      idx: json['Idx'] ?? 0,
      productCode: json['ProductCode']?.toString() ?? '',
      productName: json['ProductName']?.toString(),
      otherLanguage: json['OtherLanguage']?.toString(),
      eanCode: json['EanCode']?.toString(),
      departmentCode: json['DepartmentCode']?.toString(),
      subDepartmentCode: json['SubDepartmentCode']?.toString(),
      categoryCode: json['CategoryCode']?.toString(),
      subCategoryCode: json['SubCategoryCode']?.toString(),
      brandCode: json['BrandCode']?.toString(),
      groupCode: json['GroupCode']?.toString(),
      supplierCode: json['SupplierCode']?.toString(),
      manufacturerCode: json['ManufacturerCode']?.toString(),
      colourCode: json['ColourCode']?.toString(),
      sizeCode: json['SizeCode']?.toString(),
      partNo: json['PartNo']?.toString(),
      costPrice: safeParseDouble(json['CostPrice']),
      purchasingUnit: json['PurchasingUnit']?.toString(),
      purchasingPackSize: safeParseInt(json['PurchasingPackSize']),
      margin: safeParseDouble(json['Margin']),
      costCode: json['CostCode']?.toString(),
      unitPrice: safeParseDouble(json['UnitPrice']),
      sellingUnit: json['SellingUnit']?.toString(),
      sellingPackSize: safeParseInt(json['SellingPackSize']),
      wholeSalePrice: safeParseDouble(json['WholeSalePrice']),
      minimumPrice: safeParseDouble(json['MinimumPrice']),
      maximumPrice: safeParseDouble(json['MaximumPrice']),
      fixedDiscount: safeParseDouble(json['FixedDiscount']),
      maxDiscount: safeParseDouble(json['MaxDiscount']),
      taxPrice: safeParseDouble(json['TaxPrice']),
      reOrderQty: safeParseDouble(json['ReOrderQty']),
      reOrderPeriod: safeParseInt(json['ReOrderPeriod']),
      reOrderLevel: safeParseDouble(json['ReOrderLevel']),
      ledgertCode: json['LedgertCode']?.toString(),
      promotional: safeParseBool(json['Promotional']),
      rowmaterial: safeParseBool(json['Rowmaterial']),
      freeIssue: safeParseBool(json['FreeIssue']),
      lockReorder: safeParseBool(json['LockReorder']),
      lockProduct: safeParseBool(json['LockProduct']),
      taxItem: safeParseBool(json['TaxItem']),
      bundled: safeParseBool(json['Bundled']),
      warranty: safeParseBool(json['Warranty']),
      service: safeParseBool(json['Service']),
      lastPurchasePrice: safeParseDouble(json['LastPurchasePrice']),
      avgCostPrice: safeParseDouble(json['AvgCostPrice']),
      serialTrack: safeParseBool(json['SerialTrack']),
      serialTrackInvoice: safeParseBool(json['SerialTrackInvoice']),
      serailPick: safeParseBool(json['SerailPick']),
      warrantyTrackInvoice: safeParseBool(json['WarrantyTrackInvoice']),
      warrantyPick: safeParseBool(json['WarrantyPick']),
      warrantyPeriod: safeParseInt(json['WarrantyPeriod']),
      miscellaneous: safeParseBool(json['Miscellaneous']),
      manufactured: safeParseBool(json['Manufactured']),
      batch: safeParseBool(json['Batch']),
      expiry: safeParseBool(json['Expiry']),
      update: safeParseBool(json['Update']),
      createdDate: safeParseDateTime(json['Created_Date']),
      createdUser: json['Created_User']?.toString(),
      editedDate: safeParseDateTime(json['Edited_Date']),
      editedUser: json['Edited_User']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'Idx': idx,
    'ProductCode': productCode,
    'ProductName': productName,
    'OtherLanguage': otherLanguage,
    'EanCode': eanCode,
    'DepartmentCode': departmentCode,
    'SubDepartmentCode': subDepartmentCode,
    'CategoryCode': categoryCode,
    'SubCategoryCode': subCategoryCode,
    'BrandCode': brandCode,
    'GroupCode': groupCode,
    'SupplierCode': supplierCode,
    'ManufacturerCode': manufacturerCode,
    'ColourCode': colourCode,
    'SizeCode': sizeCode,
    'PartNo': partNo,
    'CostPrice': costPrice,
    'PurchasingUnit': purchasingUnit,
    'PurchasingPackSize': purchasingPackSize,
    'Margin': margin,
    'CostCode': costCode,
    'UnitPrice': unitPrice,
    'SellingUnit': sellingUnit,
    'SellingPackSize': sellingPackSize,
    'WholeSalePrice': wholeSalePrice,
    'MinimumPrice': minimumPrice,
    'MaximumPrice': maximumPrice,
    'FixedDiscount': fixedDiscount,
    'MaxDiscount': maxDiscount,
    'TaxPrice': taxPrice,
    'ReOrderQty': reOrderQty,
    'ReOrderPeriod': reOrderPeriod,
    'ReOrderLevel': reOrderLevel,
    'LedgertCode': ledgertCode,
    'Promotional': promotional,
    'Rowmaterial': rowmaterial,
    'FreeIssue': freeIssue,
    'LockReorder': lockReorder,
    'LockProduct': lockProduct,
    'TaxItem': taxItem,
    'Bundled': bundled,
    'Warranty': warranty,
    'Service': service,
    'LastPurchasePrice': lastPurchasePrice,
    'AvgCostPrice': avgCostPrice,
    'SerialTrack': serialTrack,
    'SerialTrackInvoice': serialTrackInvoice,
    'SerailPick': serailPick,
    'WarrantyTrackInvoice': warrantyTrackInvoice,
    'WarrantyPick': warrantyPick,
    'WarrantyPeriod': warrantyPeriod,
    'Miscellaneous': miscellaneous,
    'Manufactured': manufactured,
    'Batch': batch,
    'Expiry': expiry,
    'Update': update,
    'Created_Date': createdDate?.toIso8601String(),
    'Created_User': createdUser,
    'Edited_Date': editedDate?.toIso8601String(),
    'Edited_User': editedUser,
  };

  // Helper method to get the price
  double getPrice() {
    return price;
  }
}
