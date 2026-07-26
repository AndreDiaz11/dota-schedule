import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_item.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/drawer_menu_button.dart';
import '../widgets/state_message.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: const DrawerMenuButton(), title: const Text('Noticias')),
      body: newsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const StateMessage(
          icon: Icons.error_outline,
          message: 'No se pudieron cargar las noticias.',
        ),
        data: (items) {
          if (items.isEmpty) {
            return const StateMessage(
              icon: Icons.article_outlined,
              message: 'No hay noticias por el momento.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: items.length,
            itemBuilder: (context, index) => _NewsCard(item: items[index]),
          );
        },
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;

  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM, HH:mm', 'es').format(item.publishedAtLocal);

    return AppCard(
      onTap: () => launchUrl(Uri.parse(item.link), mode: LaunchMode.externalApplication),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.source} · $date',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
