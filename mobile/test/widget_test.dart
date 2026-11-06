import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockai_mobile/app.dart';

void main() {
  testWidgets('StockAI app smoke test', (WidgetTester tester) async {
    // Khởi chạy StockAiApp trong ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: StockAiApp(),
      ),
    );

    // Xác nhận giao diện hiển thị tên ứng dụng và trạng thái
    expect(find.text('StockAI VN'), findsOneWidget);
    expect(find.text('Trợ lý AI'), findsOneWidget);
  });
}
