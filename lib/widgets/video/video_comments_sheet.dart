import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/l10n/app_strings_provider.dart';
import 'package:signmirror_flutter/models/community_video.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/theme/community_theme.dart';

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
    ref
        .read(communityVideoProvider.notifier)
        .addComment(widget.video.id, 1, text);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final communityTheme = Theme.of(context).extension<CommunityTheme>()!;
    final textTheme = Theme.of(context).textTheme;
    final highContrast = MediaQuery.of(context).highContrast;
    final appStrings = ref.watch(appStringsProvider);

    // Re-fetch video from state to get the latest comments
    final videos = ref.watch(communityVideoProvider);
    final video = videos.firstWhere(
      (v) => v.id == widget.video.id,
      orElse: () => widget.video,
    );

    final dividerColor = highContrast
        ? communityTheme.outlineColor
        : communityTheme.dividerColor;

    final inputFillColor = communityTheme.commentFieldFillColor;

    final handleColor = highContrast
        ? communityTheme.outlineColor
        : communityTheme.sheetHandleColor;

    final primaryActionColor = communityTheme.primaryActionColor;
    final outlineColor = communityTheme.outlineColor;

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide.none,
    );

    final enabledHighContrastBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: outlineColor, width: 1.5),
    );

    final focusedHighContrastBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: primaryActionColor, width: 2.0),
    );

    final sheetShape = RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      side: highContrast
          ? BorderSide(color: outlineColor, width: 1.5)
          : BorderSide.none,
    );

    return Material(
      color: communityTheme.sheetBackgroundColor,
      shape: sheetShape,
      clipBehavior: Clip.antiAlias,
      child: Padding(
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
                color: handleColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              appStrings.communityCommentsTitleWithCount(video.comments.length),
              style: (textTheme.titleMedium ?? const TextStyle(fontSize: 16))
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Divider(color: dividerColor),
            Expanded(
              child: video.comments.isEmpty
                  ? Center(
                      child: Text(
                        appStrings.communityNoCommentsYetMessage,
                        style: textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: video.comments.length,
                      itemBuilder: (context, index) {
                        final comment = video.comments[index];
                        // Simple UI for the comment
                        return ListTile(
                          leading: const CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(
                              'assets/images/profile_picture.jpeg',
                            ),
                          ),
                          title: Text(
                            appStrings.communityUserWithId(comment.userId),
                            // Replace with actual user name logic if available
                            style:
                                (textTheme.bodyMedium ??
                                        const TextStyle(fontSize: 13))
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                          ),
                          subtitle: Text(
                            comment.text,
                            style: textTheme.bodyMedium,
                          ),
                        );
                      },
                    ),
            ),
            Divider(height: 1, color: dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(color: colorScheme.onSurface),
                      cursorColor: primaryActionColor,
                      decoration: InputDecoration(
                        hintText: appStrings.communityAddCommentHint,
                        hintStyle: TextStyle(
                          color: highContrast
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                        border: baseBorder,
                        enabledBorder: highContrast
                            ? enabledHighContrastBorder
                            : baseBorder,
                        focusedBorder: highContrast
                            ? focusedHighContrastBorder
                            : baseBorder,
                        filled: true,
                        fillColor: inputFillColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: appStrings.communitySendTooltip,
                    icon: Icon(Icons.send, color: primaryActionColor),
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
