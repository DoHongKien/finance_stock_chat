class ApiEndpoints {
  ApiEndpoints._();

  // URL chính thức của Cloudflare Worker Backend chạy 24/7 trên toàn cầu
  static const String defaultBaseUrl = 'https://stockai-worker.dohongkien2003.workers.dev';

  static const String chatEndpoint = '/api/chat';
  static const String watchlistEndpoint = '/api/watchlist';
  static const String stockInfoEndpoint = '/api/stock';
  static const String marketOverviewEndpoint = '/api/market/overview';
}
