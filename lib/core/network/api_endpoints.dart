class ApiEndpoints {
  static const String baseUrl = 'https://api.superapp.com/v1';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  
  // Shops
  static const String shops = '/shops';
  static const String shopDetails = '/shops/details';
  
  // Services
  static const String requestService = '/services/request';
  static const String acceptService = '/services/accept';
  
  // Marketplace
  static const String products = '/products';
  static const String categories = '/categories';
}
