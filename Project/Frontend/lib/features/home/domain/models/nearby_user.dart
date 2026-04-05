/// Model representing a nearby user in the Colony app
class NearbyUser {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String? profession;
  final double distanceMeters;
  final bool isOnline;
  final DateTime? lastSeen;
  final List<String>? lookingFor;
  final List<String>? interests;
  final int? colonyLevel;
  final bool isVerified;
  final bool isPremium;

  const NearbyUser({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.profession,
    required this.distanceMeters,
    this.isOnline = false,
    this.lastSeen,
    this.lookingFor,
    this.interests,
    this.colonyLevel,
    this.isVerified = false,
    this.isPremium = false,
  });

  /// Factory constructor to create from Supabase response
  factory NearbyUser.fromJson(Map<String, dynamic> json) {
    return NearbyUser(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'Unknown',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      profession: json['profession'] as String?,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      lookingFor: (json['looking_for'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      colonyLevel: json['colony_level'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
      isPremium: json['is_premium'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'profession': profession,
      'distance_meters': distanceMeters,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'looking_for': lookingFor,
      'interests': interests,
      'colony_level': colonyLevel,
      'is_verified': isVerified,
      'is_premium': isPremium,
    };
  }

  /// Get formatted distance string
  String get distanceString {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()}m away';
    } else {
      final km = distanceMeters / 1000;
      return '${km.toStringAsFixed(1)}km away';
    }
  }

  /// Get display name (full name or username)
  String get displayName => fullName?.isNotEmpty == true ? fullName! : username;

  /// Copy with new values
  NearbyUser copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? profession,
    double? distanceMeters,
    bool? isOnline,
    DateTime? lastSeen,
    List<String>? lookingFor,
    List<String>? interests,
    int? colonyLevel,
    bool? isVerified,
    bool? isPremium,
  }) {
    return NearbyUser(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      profession: profession ?? this.profession,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      lookingFor: lookingFor ?? this.lookingFor,
      interests: interests ?? this.interests,
      colonyLevel: colonyLevel ?? this.colonyLevel,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NearbyUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
