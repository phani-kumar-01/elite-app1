// ─── SUPABASE CREDENTIALS & COLLEGE DOMAIN CONFIGURATION ────────────────────
// Project reference: qjntsxlmdrldbnvmqpca
// Strict Institutional Domain: sasi.ac.in
// ─────────────────────────────────────────────────────────────────────────────
class SupabaseConfig {
  /// Supabase Project URL:
  static const String url = 'https://qjntsxlmdrldbnvmqpca.supabase.co';

  /// Supabase Anon (public) API Key:
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbnRzeGxtZHJsZGJudm1xcGNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkxODAxODksImV4cCI6MjEwNDc1NjE4OX0.wzkJ2LQz8vxAtA9ylrNbqm6P7uwiZ2GcxcG-g3Gig_o';

  /// Returns true if valid keys have been configured
  static bool get isConfigured =>
      url.trim().isNotEmpty &&
      anonKey.trim().isNotEmpty &&
      !url.contains('YOUR_SUPABASE_URL_HERE') &&
      !anonKey.contains('YOUR_SUPABASE_ANON_KEY_HERE');

  /// Strict College Domain: ONLY sasi.ac.in
  static const String collegeDomain = 'sasi.ac.in';

  /// Returns true ONLY if email belongs to @sasi.ac.in
  static bool isValidCollegeEmail(String email) {
    final trimmed = email.trim().toLowerCase();
    return trimmed.endsWith('@$collegeDomain') && trimmed.length > ('@$collegeDomain').length;
  }
}