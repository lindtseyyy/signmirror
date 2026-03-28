import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/community_video.dart';
import 'package:signmirror_flutter/providers/providers.dart';

class VideoCommentsSheet extends ConsumerStatefulWidget {
  final CommunityVideo video;

  const VideoCommentsSheet({super.key, required this.video});

  @override
  ConsumerState<VideoCommentsSheet> createState() => _VideoCommentsSheetState();
}

class _VideoCommentsSheetState extends ConsumerState<VideoCommentsSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // We assume userId 1 is the current logged-in user
    ref.read(communityVideoProvider.notifier).addComment(widget.video.id, 1, text);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Re-fetch video from state to get the latest comments
    final videos = ref.watch(communityVideoProvider);
    final video = videos.firstWhere((v) => v.id == widget.video.id, orElse: () => widget.video);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Comments (${video.comments.length})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),
          Expanded(
            child: video.comments.isEmpty
                ? const Center(child: Text("No comments yet. Be the first to comment!"))
                : ListView.builder(
                    itemCount: video.comments.length,
                    itemBuilder: (context, index) {
                      final comment = video.comments[index];
                      // Simple UI for the comment
                      return ListTile(
                        leading: const CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage('assets/images/profile_picture.jpeg'),
                        ),
                        title: Text(
                          "User ${comment.userId}", // Replace with actual user name logic if available
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(comment.text),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
