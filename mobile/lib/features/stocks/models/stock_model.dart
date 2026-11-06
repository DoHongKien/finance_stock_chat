/// Model dữ liệu chứng khoán Việt Nam tích hợp từ SSI MCP
class StockModel {
  final String symbol;
  final String companyName;
  final String exchange; // HOSE, HNX, UPCOM
  final double currentPrice;
  final double change;
  final double changePercent;
  final double refPrice;
  final double ceilingPrice;
  final double floorPrice;
  final double pe;
  final double pb;
  final double roe;
  final String marketCap;
  final List<double> sparklinePoints;
  final double healthScore; // 0 - 100
  final double buyPressure; // 0 - 100 (% lực mua chủ động)
  final String? industry;

  const StockModel({
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.refPrice,
    required this.ceilingPrice,
    required this.floorPrice,
    required this.pe,
    required this.pb,
    required this.roe,
    required this.marketCap,
    required this.sparklinePoints,
    this.healthScore = 82.0,
    this.buyPressure = 64.0,
    this.industry,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      exchange: json['exchange'] as String? ?? 'HOSE',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
      refPrice: (json['refPrice'] as num?)?.toDouble() ?? 0.0,
      ceilingPrice: (json['ceilingPrice'] as num?)?.toDouble() ?? 0.0,
      floorPrice: (json['floorPrice'] as num?)?.toDouble() ?? 0.0,
      pe: (json['pe'] as num?)?.toDouble() ?? 0.0,
      pb: (json['pb'] as num?)?.toDouble() ?? 0.0,
      roe: (json['roe'] as num?)?.toDouble() ?? 0.0,
      marketCap: json['marketCap'] as String? ?? '',
      sparklinePoints: (json['sparklinePoints'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      healthScore: (json['healthScore'] as num?)?.toDouble() ?? 80.0,
      buyPressure: (json['buyPressure'] as num?)?.toDouble() ?? 55.0,
      industry: json['industry'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'companyName': companyName,
      'exchange': exchange,
      'currentPrice': currentPrice,
      'change': change,
      'changePercent': changePercent,
      'refPrice': refPrice,
      'ceilingPrice': ceilingPrice,
      'floorPrice': floorPrice,
      'pe': pe,
      'pb': pb,
      'roe': roe,
      'marketCap': marketCap,
      'sparklinePoints': sparklinePoints,
      'healthScore': healthScore,
      'buyPressure': buyPressure,
      'industry': industry,
    };
  }
}

