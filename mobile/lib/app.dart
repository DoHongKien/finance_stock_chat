import 'package:flutter/material.dart';
import 'core/theme/mobile_theme.dart';
import 'layout/app_main_scaffold.dart';

class StockAiApp extends StatelessWidget {
  const StockAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockAI VN',
      debugShowCheckedModeBanner: false,
      theme: MobileFinanceTheme.darkTheme,
      builder: (context, child) {
        return Container(
          color: const Color(0xFF030712), // Nền ngoài khi mở trên màn hình rộng
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRect(child: child),
            ),
          ),
        );
      },
      home: const AppMainScaffold(),
    );
  }
}
