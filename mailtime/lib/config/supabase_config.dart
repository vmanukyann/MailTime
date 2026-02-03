import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static void validate() {
    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Missing Supabase configuration. Ensure SUPABASE_URL and '
        'SUPABASE_ANON_KEY are set in your .env file.',
      );
    }
  }
}
