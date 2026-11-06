import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../stocks/models/stock_model.dart';
import '../models/watchlist_item.dart';

class WatchlistState {
  final List<WatchlistItem> items;
  final bool isLoading;

  const WatchlistState({
    this.items = const [],
    this.isLoading = false,
  });

  WatchlistState copyWith({
    List<WatchlistItem>? items,
    bool? isLoading,
  }) {
    return WatchlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WatchlistController extends StateNotifier<WatchlistState> {
  static const String _storageKey = 'stockai_watchlist_v1';

  WatchlistController() : super(const WatchlistState()) {
    _loadFromLocal();
  }

  Future<void> _loadFromLocal() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final loaded = list.map((e) => WatchlistItem.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(items: loaded, isLoading: false);
        return;
      }
    } catch (_) {}

    // Dữ liệu mẫu khởi đầu hữu ích cho nhà đầu tư
    final initialList = [
      WatchlistItem(
        symbol: 'FPT',
        note: 'Cổ phiếu công nghệ đầu ngành',
        addedAt: DateTime.now(),
        liveData: const StockModel(
          symbol: 'FPT',
          companyName: 'Công ty Cổ phần FPT',
          exchange: 'HOSE',
          currentPrice: 135.5,
          change: 3.1,
          changePercent: 2.34,
          refPrice: 132.4,
          ceilingPrice: 141.6,
          floorPrice: 123.2,
          pe: 21.5,
          pb: 5.2,
          roe: 27.8,
          marketCap: '198.5 Tỷ',
          sparklinePoints: [132.4, 133.0, 132.8, 134.2, 134.0, 135.0, 135.5],
        ),
      ),
      WatchlistItem(
        symbol: 'HPG',
        note: 'Dự án Dung Quất 2',
        addedAt: DateTime.now(),
        liveData: const StockModel(
          symbol: 'HPG',
          companyName: 'Tập đoàn Hòa Phát',
          exchange: 'HOSE',
          currentPrice: 28.2,
          change: 0.2,
          changePercent: 0.71,
          refPrice: 28.0,
          ceilingPrice: 29.95,
          floorPrice: 26.05,
          pe: 11.8,
          pb: 1.6,
          roe: 14.5,
          marketCap: '164.2 Tỷ',
          sparklinePoints: [28.0, 28.1, 27.9, 28.3, 28.15, 28.2],
        ),
      ),
      WatchlistItem(
        symbol: 'MBB',
        note: 'Ngân hàng Quân Đội',
        addedAt: DateTime.now(),
        liveData: const StockModel(
          symbol: 'MBB',
          companyName: 'Ngân hàng TMCP Quân Đội',
          exchange: 'HOSE',
          currentPrice: 24.5,
          change: -0.15,
          changePercent: -0.61,
          refPrice: 24.65,
          ceilingPrice: 26.35,
          floorPrice: 22.95,
          pe: 6.2,
          pb: 1.1,
          roe: 22.1,
          marketCap: '128.0 Tỷ',
          sparklinePoints: [24.65, 24.8, 24.6, 24.4, 24.5],
        ),
      ),
    ];

    state = state.copyWith(items: initialList, isLoading: false);
    _saveToLocal(initialList);
  }

  Future<void> _saveToLocal(List<WatchlistItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }

  bool isBookmarked(String symbol) {
    return state.items.any((i) => i.symbol.toUpperCase() == symbol.toUpperCase());
  }

  void toggleWatchlist(StockModel stock) {
    final exists = isBookmarked(stock.symbol);
    if (exists) {
      removeSymbol(stock.symbol);
    } else {
      addStock(stock);
    }
  }

  void addStock(StockModel stock) {
    if (isBookmarked(stock.symbol)) return;
    final newItem = WatchlistItem(
      symbol: stock.symbol,
      companyName: stock.companyName,
      addedAt: DateTime.now(),
      liveData: stock,
    );
    final updated = [newItem, ...state.items];
    state = state.copyWith(items: updated);
    _saveToLocal(updated);
  }

  void removeSymbol(String symbol) {
    final updated = state.items.where((i) => i.symbol.toUpperCase() != symbol.toUpperCase()).toList();
    state = state.copyWith(items: updated);
    _saveToLocal(updated);
  }
}

final watchlistControllerProvider =
    StateNotifierProvider<WatchlistController, WatchlistState>((ref) {
  return WatchlistController();
});

