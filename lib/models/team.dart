enum Region { na, sa, eu, cn, sea, other }

class Team {
  final String id;
  final String name;
  final String logoUrl;
  final Region region;

  const Team({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.region,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'].toString(),
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String? ?? '',
      region: Region.values.firstWhere(
        (r) => r.name == json['region'],
        orElse: () => Region.other,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logoUrl': logoUrl,
        'region': region.name,
      };
}
