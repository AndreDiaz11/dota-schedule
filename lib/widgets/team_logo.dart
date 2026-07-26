import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TeamLogo extends StatelessWidget {
  final String logoUrl;
  final String teamName;
  final double size;

  const TeamLogo({super.key, required this.logoUrl, required this.teamName, this.size = 28});

  @override
  Widget build(BuildContext context) {
    if (logoUrl.isEmpty) {
      return _fallback();
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: logoUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (context, url) => _fallback(),
        errorWidget: (context, url, error) => _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.chipBackground,
      child: Text(
        teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
