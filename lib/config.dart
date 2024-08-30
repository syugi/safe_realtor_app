import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static final String apiBaseUrl =
      dotenv.env['API_URL'] ?? 'http://default-url.com';
}
