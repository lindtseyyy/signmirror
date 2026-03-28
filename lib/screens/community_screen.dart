import 'package:signmirror_flutter/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/community_video.dart';
import 'package:signmirror_flutter/widgets/video/video_dialog.dart';
import 'package:signmirror_flutter/widgets/video/video_comments_sheet.dart';
import 'package:signmirror_flutter/providers/providers.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    final communityVideos = ref.watch(communityVideoProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          title: const Text(
            "Community",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
          ), // Sets color for icons and text
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,

          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: // Use Expanded so the ListView takes the remaining screen space
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: communityVideos.length,
                    itemBuilder: (context, index) {
                      final video = communityVideos[index];
                      return _buildCommunityPost(context, ref, video);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildVideoThumbnail(
  BuildContext context,
  String thumbnailUrl,
  String videoUrl,
) {
  return GestureDetector(
    onTap: () =>
        _openVideoPlayer(context, videoUrl), // Logic to open the player
    behavior: HitTestBehavior.opaque,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // 1. The Image Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AdaptiveImage(
            thumbnailUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // 2. Dark Overlay to make the icon pop
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // 3. The Play Icon
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white70,
          child: Icon(Icons.play_arrow, size: 40, color: Colors.black),
        ),
      ],
    ),
  );
}

void _openVideoPlayer(BuildContext context, String videoUrl) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => VideoDialog(videoUrl: videoUrl),
  );
}

Widget _buildCommunityPost(
  BuildContext context,
  WidgetRef ref,
  CommunityVideo video,
) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 0.5,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. The Video Thumbnail (The part that opens the player)
        Container(
          child: _buildVideoThumbnail(
            context,
            "assets/images/sign.png",
            video.videoUrl,
          ),
        ),
        // 1. User Header
        ListTile(
          leading: const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/profile_picture.jpeg'),
          ),

          title: Text(
            "Bob Smith",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: video.approves >= 3
                  ? Colors.green.shade50
                  : Colors.transparent,
              border: Border.all(
                color: video.approves >= 3 ? Colors.green : Colors.orange,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (video.approves >= 3)
                  const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(Icons.verified, color: Colors.green, size: 14),
                  ),
                Text(
                  video.approves >= 3
                      ? "Top Approved (${video.approves})"
                      : "${video.approves}/3 Approved",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: video.approves >= 3
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: video.approves >= 3 ? Colors.green.shade800 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey.shade200,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          width: double.infinity,
          child: Text(video.description!, textAlign: TextAlign.justify),
        ),
        // 3. Interaction Bar (Likes/Comments)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton(
                onPressed: () {
                  ref
                      .read(communityVideoProvider.notifier)
                      .toggleApprove(video.id);
                },
                style: video.isApprovedByCurrentUser
                    ? FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Color(0xff69B85E),

                        fixedSize: const Size(130, 40),
                      )
                    : FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: const Size(130, 40),
                      ),
                child: Text(
                  video.isApprovedByCurrentUser ? "Approved!" : "Approve",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: VideoCommentsSheet(video: video),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.comment_outlined),
                    const SizedBox(width: 10),
                    Text(
                      "${video.comments.length} ${video.comments.length == 1 ? 'Comment' : 'Comments'}",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
