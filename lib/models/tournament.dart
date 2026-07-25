enum TournamentTier { tier1, tier2, tier3, qualifier, amateur }

class Tournament {
  final String id;
  final String name;
  final TournamentTier tier;

  const Tournament({
    required this.id,
    required this.name,
    required this.tier,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'].toString(),
      name: json['name'] as String,
      tier: TournamentTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => TournamentTier.amateur,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tier': tier.name,
      };
}
