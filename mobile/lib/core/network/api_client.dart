import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';

class ApiClient {
  final Dio _dio;
  String _baseUrl = ApiEndpoints.defaultBaseUrl;
  String? _authToken;

  ApiClient({String? baseUrl, String? authToken})
      : _baseUrl = baseUrl ?? ApiEndpoints.defaultBaseUrl,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? ApiEndpoints.defaultBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _authToken = authToken;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          debugPrint('[ApiClient Error] ${error.message} - ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  void updateToken(String token) {
    _authToken = token;
  }

  void updateBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  String get baseUrl => _baseUrl;

  /// Gửi câu hỏi chat đến Cloudflare Worker (Gemini + SSI MCP)
  Future<Map<String, dynamic>> sendChatMessage({
    required String query,
    String? conversationId,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.chatEndpoint,
        data: {
          'query': query,
          'conversation_id': conversationId,
          'locale': 'vi_VN',
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'content': response.data.toString()};
    } catch (e) {
      debugPrint('[ApiClient] API Worker chưa khả dụng hoặc ngoại lệ: $e');
      // Trả fallback giả lập thông minh hỗ trợ phát triển giao diện trước khi Worker deploy
      return _generateMockChatResponse(query);
    }
  }

  /// Mock thông minh cho các câu hỏi phổ biến khi đang phát triển giao diện
  Map<String, dynamic> _generateMockChatResponse(String query) {
    final upper = query.toUpperCase();
    if (upper.contains('FPT')) {
      return {
        'content':
            'Cổ phiếu **FPT (CTCP FPT)** hôm nay giao dịch tích cực quanh mốc **135.500 ₫**, tăng **+2.34%** so với phiên trước. Chỉ số P/E hiện tại ở mức 21.5 lần, ROE duy trì xuất sắc 27.8% nhờ mảng Chuyển đổi số và Xuất khẩu phần mềm tăng trưởng 2 con số.',
        'stock_data': {
          'symbol': 'FPT',
          'companyName': 'Công ty Cổ phần FPT',
          'exchange': 'HOSE',
          'currentPrice': 135.5,
          'change': 3.1,
          'changePercent': 2.34,
          'refPrice': 132.4,
          'ceilingPrice': 141.6,
          'floorPrice': 123.2,
          'pe': 21.5,
          'pb': 5.2,
          'roe': 27.8,
          'marketCap': '198.5 Tỷ',
          'sparklinePoints': [132.4, 133.0, 132.8, 134.2, 134.0, 135.0, 135.5],
        },
        'follow_ups': [
          'Biên lợi nhuận ròng FPT quý 3 thế nào?',
          'Khối ngoại mua ròng FPT bao nhiêu?',
          'So sánh P/E của FPT và MWG'
        ],
      };
    } else if (upper.contains('HPG')) {
      return {
        'content':
            'Cổ phiếu **HPG (Tập đoàn Hòa Phát)** đóng cửa ở mức **28.200 ₫**, biến động nhẹ **+0.71%**. Khối lượng khớp lệnh đạt hơn 18.5 triệu cổ phiếu. Dự án Dung Quất 2 tiếp tục là động lực tăng trưởng dài hạn cho doanh nghiệp.',
        'stock_data': {
          'symbol': 'HPG',
          'companyName': 'Tập đoàn Hòa Phát',
          'exchange': 'HOSE',
          'currentPrice': 28.2,
          'change': 0.2,
          'changePercent': 0.71,
          'refPrice': 28.0,
          'ceilingPrice': 29.95,
          'floorPrice': 26.05,
          'pe': 11.8,
          'pb': 1.6,
          'roe': 14.5,
          'marketCap': '164.2 Tỷ',
          'sparklinePoints': [28.0, 28.1, 27.9, 28.3, 28.15, 28.2],
        },
        'follow_ups': [
          'Giá thép thế giới ảnh hưởng gì tới HPG?',
          'Tiến độ dự án Dung Quất 2 đến đâu rồi?',
          'Định giá P/B của HPG có rẻ không?'
        ],
      };
    } else {
      return {
        'content':
            'Hôm nay chỉ số **VN-Index** tăng **+12.45 điểm (+0.98%)** lên mốc **1,288.50 điểm**. Thanh khoản toàn thị trường đạt hơn 17.800 tỷ đồng. Nhóm cổ phiếu Công nghệ, Ngân hàng và Thép dẫn dắt chỉ số chung.',
        'stock_data': null,
        'follow_ups': [
          'Cổ phiếu FPT hôm nay giá bao nhiêu?',
          'Top cổ phiếu khối ngoại mua ròng nhiều nhất?',
          'Tình hình HPG quý vừa qua thế nào?'
        ],
      };
    }
  }
}
