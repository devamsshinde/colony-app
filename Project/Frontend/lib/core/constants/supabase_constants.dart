/// Supabase Configuration Constants
///
/// Replace these placeholder values with your actual Supabase project credentials
/// from the Supabase Dashboard > Settings > API
class SupabaseConstants {
  SupabaseConstants._();

  /// Supabase Project URL
  /// Get this from: Supabase Dashboard > Settings > API > Project URL
  static const String supabaseUrl = 'https://pfcqskmitzeclipipvak.supabase.co';

  /// Supabase Anonymous Key
  /// Get this from: Supabase Dashboard > Settings > API > Project API keys > anon public
  /// This key is safe to expose in client-side code
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBmY3Fza21pdHplY2xpcGlwdmFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyMTI3NjQsImV4cCI6MjA5MDc4ODc2NH0.YY3yWVWAiTadyxiJLrZiO_99ccfmF_Ld-JA2aFXAVGM';

  /// Supabase Service Role Key (DO NOT use in client-side code)
  /// This should only be used in backend/server environments
  /// Get this from: Supabase Dashboard > Settings > API > Project API keys > service_role
  static const String supabaseServiceRoleKey = 'your-service-role-key-here';

  /// JWT Secret (for backend use only)
  /// Get this from: Supabase Dashboard > Settings > API > JWT Secret
  static const String jwtSecret = 'your-jwt-secret-here';

  /// Storage Bucket Names
  static const String profileImagesBucket = 'profile-images';
  static const String storyImagesBucket = 'story-images';
  static const String groupImagesBucket = 'group-images';
  static const String chatMediaBucket = 'chat-media';

  /// Table Names
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
  static const String groupsTable = 'groups';
  static const String groupMembersTable = 'group_members';
  static const String postsTable = 'posts';
  static const String storiesTable = 'stories';
  static const String chatsTable = 'chats';
  static const String messagesTable = 'messages';
  static const String eventsTable = 'events';
  static const String notificationsTable = 'notifications';
  static const String locationsTable = 'locations';
}
