import 'package:flutter/material.dart';

import '../models/team.dart';

class TeamTile extends StatelessWidget {
  final Team team;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const TeamTile({
    super.key,
    required this.team,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  static const _regionLabels = {
    Region.na: 'Norteamérica',
    Region.sa: 'Sudamérica',
    Region.eu: 'Europa',
    Region.cn: 'China',
    Region.sea: 'Sudeste Asiático',
    Region.other: 'Otra región',
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(team.name.isNotEmpty ? team.name[0] : '?')),
      title: Text(team.name),
      subtitle: Text(_regionLabels[team.region] ?? ''),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? Colors.amber : null,
        ),
        onPressed: onToggleFavorite,
      ),
    );
  }
}
