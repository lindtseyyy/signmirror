import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/screens/dictionary_sign_screen.dart';

class BookmarkedSignsScreen extends ConsumerWidget {
  const BookmarkedSignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedSigns = ref.watch(bookmarkedSignsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmarked Signs',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: const Color(0xff304166),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.fromLTRB(15, 20, 15, 0),
        child: bookmarkedSigns.isEmpty
            ? const Center(child: Text('No bookmarked signs.'))
            : _BookmarkedSignsList(signs: bookmarkedSigns),
      ),
    );
  }
}

class _BookmarkedSignsList extends ConsumerWidget {
  final List<Sign> signs;

  const _BookmarkedSignsList({required this.signs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: signs.length,
      itemBuilder: (context, index) {
        final sign = signs[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0))],
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DictionarySignScreen(sign: sign),
                ),
              );
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            title: Text(
              sign.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Row(
                  children: [
                    Text(
                      '${sign.category} Sign',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.bookmark,
                size: 20,
                color: Color(0xff304166),
              ),
              onPressed: () async {
                await ref.read(signsProvider.notifier).toggleBookmark(sign);
                await ref.read(bookmarkedSignsProvider.notifier).loadAll();
              },
              tooltip: 'Remove bookmark',
            ),
          ),
        );
      },
    );
  }
}
