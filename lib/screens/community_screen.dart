import 'package:signmirror_flutter/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/community_video.dart';
import 'package:signmirror_flutter/widgets/video/video_dialog.dart';
import 'package:signmirror_flutter/widgets/video/video_comments_sheet.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/constants/route_names.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  static const int _currentUserId = 1;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final Map<int, List<Comment>> _mockVideoComments = <int, List<Comment>>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _resolveUploaderName(Map<int, String> uploaderNames, int uploaderId) {
    return uploaderNames[uploaderId] ?? 'User $uploaderId';
  }

  List<CommunityVideo> _createMockUnapprovedVideos() {
    CommunityVideo mockVideo({
      required int id,
      required String title,
      required String description,
    }) {
      return CommunityVideo()
        ..id = id
        ..title = title
        ..description = description
        ..videoUrl = 'assets/videos/sample_portrait_video.mp4'
        ..comments = <Comment>[]
        ..approves = 0
        ..uploaderId = 2
        ..isApprovedByCurrentUser = false;
    }

    return <CommunityVideo>[
      mockVideo(
        id: -101,
        title: 'Beginner Practice Clip (Mock)',
        description:
            'Example community video shown while there are no uploads.',
      ),
    ];
  }

  Widget _buildVideoList({
    required List<CommunityVideo> videos,
    required Map<int, String> uploaderNames,
    required bool Function(CommunityVideo video) tabFilter,
  }) {
    final queryLower = _query.trim().toLowerCase();
    var filtered = videos.where((video) {
      if (!tabFilter(video)) return false;

      if (queryLower.isEmpty) return true;

      final uploaderName = _resolveUploaderName(
        uploaderNames,
        video.uploaderId,
      );
      return video.title.toLowerCase().contains(queryLower) ||
          uploaderName.toLowerCase().contains(queryLower);
    }).toList();

    if (filtered.isEmpty &&
        queryLower.isEmpty &&
        tabFilter(_createMockUnapprovedVideos().first)) {
      filtered = _createMockUnapprovedVideos();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(2.0),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final video = filtered[index];
        final uploaderName = _resolveUploaderName(
          uploaderNames,
          video.uploaderId,
        );
        return _buildCommunityPost(context, ref, video, uploaderName);
      },
    );
  }

  List<CommunityVideo> _createMockUserUploadedVideos() {
    CommunityVideo mockVideo({
      required int id,
      required String title,
      required String description,
    }) {
      return CommunityVideo()
        ..id = id
        ..title = title
        ..description = description
        ..videoUrl = 'assets/videos/sample_portrait_video.mp4'
        ..comments = <Comment>[]
        ..approves = 0
        ..uploaderId = _currentUserId
        ..isApprovedByCurrentUser = false;
    }

    return <CommunityVideo>[
      mockVideo(
        id: -1,
        title: 'My First Upload (Mock)',
        description: 'Example upload shown because you have no uploads yet.',
      ),
      mockVideo(
        id: -2,
        title: 'Practice Video (Mock)',
        description: 'Record and upload a video to replace this mock item.',
      ),
    ];
  }

  Widget _buildUserUploadedVideosTab({
    required List<CommunityVideo> videos,
    required Map<int, String> uploaderNames,
  }) {
    final queryLower = _query.trim().toLowerCase();

    final userVideos = videos
        .where((v) => v.uploaderId == _currentUserId)
        .toList();
    final baseList = userVideos.isEmpty
        ? _createMockUserUploadedVideos()
        : userVideos;

    final filtered = baseList.where((video) {
      if (queryLower.isEmpty) return true;

      final uploaderName = _resolveUploaderName(
        uploaderNames,
        video.uploaderId,
      );
      return video.title.toLowerCase().contains(queryLower) ||
          uploaderName.toLowerCase().contains(queryLower);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(2.0),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final video = filtered[index];
        return _buildUserUploadedPost(context, video);
      },
    );
  }

  Widget _buildUserUploadedPost(BuildContext context, CommunityVideo video) {
    final commentCount = (video.id < 0)
        ? (_mockVideoComments[video.id]?.length ?? video.comments.length)
        : video.comments.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: _buildVideoThumbnail(
              context,
              'assets/images/sign.png',
              video.videoUrl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.thumb_up_alt_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${video.approves} Approvals',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if ((video.description ?? '').trim().isNotEmpty)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade200,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              width: double.infinity,
              child: Text(video.description!, textAlign: TextAlign.justify),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _openCommentsForUserUpload(context, video),
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined),
                      const SizedBox(width: 10),
                      Text(
                        '$commentCount ${commentCount == 1 ? 'Comment' : 'Comments'}',
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

  @override
  Widget build(BuildContext context) {
    final communityVideos = ref.watch(communityVideoProvider);
    final uploaderNamesAsync = ref.watch(uploaderNamesProvider);

    final colorScheme = Theme.of(context).colorScheme;

    final uploaderNames = uploaderNamesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => <int, String>{},
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          title: const Text(
            'Community',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
          ),
          actions: [
            IconButton(
              tooltip: 'Upload',
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(RouteNames.communityUpload);
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(104),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: Colors.black87),
                      cursorColor: Colors.black87,
                      decoration: InputDecoration(
                        hintText: 'Search by title or uploader',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        prefixIconColor: Colors.black54,
                        hintStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                TabBar(
                  labelColor: colorScheme.onPrimary,
                  unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.75),
                  indicatorColor: colorScheme.onPrimary,
                  tabs: [
                    Tab(
                      icon: Tooltip(
                        message: 'Unapproved Videos',
                        child: Icon(
                          Icons.pending_actions,
                          semanticLabel: 'Unapproved Videos',
                        ),
                      ),
                    ),
                    Tab(
                      icon: Tooltip(
                        message: 'Approved Videos',
                        child: Icon(
                          Icons.verified,
                          semanticLabel: 'Approved Videos',
                        ),
                      ),
                    ),
                    Tab(
                      icon: Tooltip(
                        message: 'User Uploaded Videos',
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          semanticLabel: 'User Uploaded Videos',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildVideoList(
              videos: communityVideos,
              uploaderNames: uploaderNames,
              tabFilter: (video) =>
                  video.approves < 3 && video.uploaderId != _currentUserId,
            ),
            _buildVideoList(
              videos: communityVideos,
              uploaderNames: uploaderNames,
              tabFilter: (video) =>
                  video.approves >= 3 && video.uploaderId != _currentUserId,
            ),
            _buildUserUploadedVideosTab(
              videos: communityVideos,
              uploaderNames: uploaderNames,
            ),
          ],
        ),
      ),
    );
  }

  void _openCommentsForUserUpload(BuildContext context, CommunityVideo video) {
    if (video.id > 0) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: VideoCommentsSheet(video: video),
        ),
      );
      return;
    }

    final initial = List<Comment>.from(
      _mockVideoComments[video.id] ?? video.comments,
    );
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              void submit() {
                final text = commentController.text.trim();
                if (text.isEmpty) return;

                final comment = Comment()
                  ..userId = _currentUserId
                  ..text = text;
                initial.add(comment);
                _mockVideoComments[video.id] = List<Comment>.from(initial);

                commentController.clear();
                setState(() {});
                setSheetState(() {});
              }

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
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
                      'Comments (${initial.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: initial.isEmpty
                          ? const Center(
                              child: Text(
                                'No comments yet. Be the first to comment!',
                              ),
                            )
                          : ListView.builder(
                              itemCount: initial.length,
                              itemBuilder: (context, index) {
                                final comment = initial[index];
                                return ListTile(
                                  leading: const CircleAvatar(
                                    radius: 16,
                                    backgroundImage: AssetImage(
                                      'assets/images/profile_picture.jpeg',
                                    ),
                                  ),
                                  title: Text(
                                    'User ${comment.userId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  subtitle: Text(comment.text),
                                );
                              },
                            ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => submit(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.blue),
                            onPressed: submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(commentController.dispose);
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
  String uploaderName,
) {
  final hasDescription = video.description?.trim().isNotEmpty == true;
  final isMock = video.id < 0;

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 0.5,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: _buildVideoThumbnail(
            context,
            'assets/images/sign.png',
            video.videoUrl,
          ),
        ),
        ListTile(
          leading: const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/profile_picture.jpeg'),
          ),
          title: Text(
            uploaderName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            video.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: video.approves >= 3
                  ? Colors.green.shade50
                  : Colors.transparent,
              border: Border.all(
                color: video.approves >= 3 ? Colors.green : Colors.orange,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMock) ...[
                  const Icon(Icons.science_outlined, size: 14),
                  const SizedBox(width: 4),
                ],
                if (video.approves >= 3)
                  const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(Icons.verified, color: Colors.green, size: 14),
                  ),
                Text(
                  isMock
                      ? 'Mock Video'
                      : video.approves >= 3
                      ? 'Top Approved (${video.approves})'
                      : '${video.approves}/3 Approved',
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
        if (hasDescription)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade200,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            width: double.infinity,
            child: Text(video.description!, textAlign: TextAlign.justify),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton(
                onPressed: isMock
                    ? null
                    : () {
                        ref
                            .read(communityVideoProvider.notifier)
                            .toggleApprove(video.id);
                      },
                style: video.isApprovedByCurrentUser
                    ? FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color(0xff69B85E),
                        fixedSize: const Size(130, 40),
                      )
                    : FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: const Size(130, 40),
                      ),
                child: Text(
                  video.isApprovedByCurrentUser ? 'Approved!' : 'Approve',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: isMock
                    ? null
                    : () {
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
                    const Icon(Icons.comment_outlined),
                    const SizedBox(width: 10),
                    Text(
                      '${video.comments.length} ${video.comments.length == 1 ? 'Comment' : 'Comments'}',
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
