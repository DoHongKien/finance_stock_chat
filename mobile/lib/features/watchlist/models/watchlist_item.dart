import '../../stocks/models/stock_model.dart';

class WatchlistItem {
  final String symbol;
  final String? companyName;
  final String? note;
  final double? targetPrice;
  final DateTime addedAt;
  final StockModel? liveData;

  const WatchlistItem({
    required this.symbol,
    this.companyName,
    this.note,
    this.targetPrice,
    required this.addedAt,
    this.liveData,
  });

  WatchlistItem copyWith({
    String? symbol,
    String? companyName,
    String? note,
    double? targetPrice,
    DateTime? addedAt,
    StockModel? liveData,
  }) {
    return WatchlistItem(
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      note: note ?? this.note,
      targetPrice: targetPrice ?? this.targetPrice,
      addedAt: addedAt ?? this.addedAt,
      liveData: liveData ?? this.liveData,
    );
  }

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      symbol: json['symbol'] as String,
      companyName: json['company_name'] as String?,
      note: json['note'] as String?,
      targetPrice: (json['target_price'] as num?)?.toDouble(),
      addedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      liveData: json['live_data'] != null
          ? StockModel.fromJson(json['live_data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'company_name': companyName,
      'note': note,
      'target_price': targetPrice,
      'created_at': addedAt.toIso8601String(),
    };
  }
}
