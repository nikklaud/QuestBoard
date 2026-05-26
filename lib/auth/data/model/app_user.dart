class AppUser {
  final String id;
  final String email;
  final String nickname;
  final List<String> myCampaignIds;
  final List<String> joinedCampaignIds;

  AppUser({
    required this.id,
    required this.email,
    required this.nickname,
    this.myCampaignIds = const [],
    this.joinedCampaignIds = const [],
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      myCampaignIds: List<String>.from(data['myCampaignIds'] ?? []),
      joinedCampaignIds: List<String>.from(data['joinedCampaignIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nickname': nickname,
      'myCampaignIds': myCampaignIds,
      'joinedCampaignIds': joinedCampaignIds,
    };
  }
}
