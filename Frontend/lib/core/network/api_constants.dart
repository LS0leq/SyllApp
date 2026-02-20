


class ApiConstants {
  ApiConstants._();

  
  static const String baseUrl = 'https://syllapp.onrender.com';

  
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  

  
  static const String projects = '/notes';
  static String projectById(String id) => '/notes/$id';
  static String projectContent(String id) => '/notes/$id'; 

  
  static const String scrapeRhymes = '/scrape/';

  
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
