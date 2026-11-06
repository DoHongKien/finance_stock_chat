import 'package:intl/intl.dart';

class StockFormatters {
  StockFormatters._();

  static final NumberFormat _currencyFormatter = NumberFormat('#,##0.00', 'vi_VN');
  static final NumberFormat _integerFormatter = NumberFormat('#,##0', 'vi_VN');

  /// Định dạng giá cổ phiếu Việt Nam (ví dụ 135.5 -> "135.50")
  static String formatPrice(double price) {
    return _currencyFormatter.format(price);
  }

  /// Định dạng khối lượng giao dịch rút gọn (VD: 4500000 -> "4.50M CP")
  static String formatVolume(num volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(2)}B CP';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M CP';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K CP';
    }
    return '${_integerFormatter.format(volume)} CP';
  }

  /// Định dạng giá trị tiền tệ lớn (VD: 12500000000 -> "12.5 Tỷ")
  static String formatLargeValue(num value) {
    if (value.abs() >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} Tỷ';
    } else if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} Tr';
    }
    return _integerFormatter.format(value);
  }

  /// Định dạng % biến động kèm dấu + hoặc -
  static String formatPercent(double percent) {
    final prefix = percent > 0 ? '+' : '';
    return '$prefix${percent.toStringAsFixed(2)}%';
  }
}

