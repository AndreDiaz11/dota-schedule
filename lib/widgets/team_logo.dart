import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/team.dart';
import '../theme/app_theme.dart';

class TeamLogo extends StatelessWidget {
  final String logoUrl;
  final String teamName;
  final Region region;
  final double size;

  const TeamLogo({
    super.key,
    required this.logoUrl,
    required this.teamName,
    required this.region,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: regionColor(region), width: 2),
      ),
      padding: const EdgeInsets.all(1.5),
      child: logoUrl.isEmpty
          ? _fallback()
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => _fallback(),
                errorWidget: (context, url, error) => _fallback(),
              ),
            ),
    );
  }

  Widget _fallback() {
    return CircleAvatar(
      backgroundColor: AppColors.chipBackground,
      child: Text(
        teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
