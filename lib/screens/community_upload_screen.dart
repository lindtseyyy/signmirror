import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/providers/providers.dart';

class CommunityUploadScreen extends ConsumerStatefulWidget {
  const CommunityUploadScreen({super.key});

  @override
  ConsumerState<CommunityUploadScreen> createState() =>
      _CommunityUploadScreenState();
}

class _CommunityUploadScreenState extends ConsumerState<CommunityUploadScreen> {
  static const int _uploaderId = 1;

  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _videoPickerFocusNode = FocusNode(debugLabel: 'videoPicker');

  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isUploading = false;

  @override
  void dispose() {
    _videoPickerFocusNode.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isUsableLocalPath(String? path) {
    if (path == null) return false;
    final trimmed = path.trim();
    if (trimmed.isEmpty) return false;
    try {
      return File(trimmed).existsSync();
    } catch (_) {
      return false;
    }
  }

  void _setSelectedVideo({required String path, required String name}) {
    if (!mounted) return;
    setState(() {
      _selectedFilePath = path;
      _selectedFileName = name;
    });
  }

  Future<bool> _pickVideoWithFileSelector() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const <XTypeGroup>[
          XTypeGroup(
            label: 'video',
            extensions: <String>['mp4', 'mov', 'm4v', 'webm', 'mkv', 'avi'],
          ),
        ],
      );

      // User canceled: no-op (no snackbar).
      if (file == null) return false;

      final path = file.path;
      if (!_isUsableLocalPath(path)) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't access a usable local file path from the fallback picker.",
            ),
          ),
        );
        return false;
      }

      _setSelectedVideo(path: path, name: file.name);
      return true;
    } on MissingPluginException {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file picker plugin is available on this platform.'),
        ),
      );
      return false;
    } on PlatformException {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the fallback file picker.'),
        ),
      );
      return false;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong selecting a video.'),
        ),
      );
      return false;
    }
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: false,
      );

      // User canceled: no-op (no snackbar).
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final path = file.path;

      // Some platforms (notably web) cannot provide a local filesystem path.
      if (!_isUsableLocalPath(path)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "This platform can't provide an accessible local file path.",
            ),
          ),
        );
        return;
      }

      _setSelectedVideo(path: path!, name: file.name);
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the file picker.')),
      );
    } on MissingPluginException {
      // Fallback: some targets fail to register `file_picker`.
      await _pickVideoWithFileSelector();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong selecting a video.'),
        ),
      );
    }
  }

  Future<void> _upload() async {
    final path = _selectedFilePath;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a video file.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await ref
          .read(communityVideoProvider.notifier)
          .uploadVideo(
            videoFile: File(path),
            description: _descriptionController.text.trim(),
            uploaderId: _uploaderId,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload successful.')));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bool highContrast = mediaQuery.highContrast;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool hasValidVideo =
        _selectedFilePath != null && _selectedFilePath!.trim().isNotEmpty;

    final String fileNameLabel = _selectedFileName == null
        ? 'No video selected'
        : _selectedFileName!;

    final Color secondaryTextColor = highContrast
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    final double borderWidth = highContrast ? 2 : 1;
    final Color defaultOutlineColor = highContrast
        ? colorScheme.onSurface
        : colorScheme.outline;

    final BorderSide pickerBorderSide = BorderSide(
      color: hasValidVideo ? colorScheme.primary : defaultOutlineColor,
      width: borderWidth,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                // Text(
                //   'Upload video',
                //   style: theme.textTheme.headlineSmall?.copyWith(
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
                const SizedBox(height: 6),
                Text(
                  'Choose a video file, add an optional description, then upload it to the community.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Video', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                Semantics(
                  container: true,
                  button: true,
                  enabled: !_isUploading,
                  label: hasValidVideo
                      ? 'Selected video'
                      : 'Choose a video to upload',
                  value: fileNameLabel,
                  hint: _isUploading
                      ? 'Upload in progress'
                      : 'Tap to open the video picker',
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    color: hasValidVideo
                        ? colorScheme.secondaryContainer
                        : colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: pickerBorderSide,
                    ),
                    child: InkWell(
                      focusNode: _videoPickerFocusNode,
                      canRequestFocus: !_isUploading,
                      onTap: _isUploading ? null : _pickVideo,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              hasValidVideo
                                  ? Icons.check_circle
                                  : Icons.videocam_outlined,
                              color: hasValidVideo
                                  ? colorScheme.primary
                                  : secondaryTextColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hasValidVideo
                                        ? 'Video selected'
                                        : 'Pick a video',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fileNameLabel,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: hasValidVideo
                                          ? colorScheme.onSecondaryContainer
                                          : secondaryTextColor,
                                    ),
                                  ),
                                  if (!hasValidVideo) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Supported: MP4, MOV, M4V, WebM, MKV, AVI',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: secondaryTextColor),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Tooltip(
                              message: hasValidVideo
                                  ? 'Change selected video'
                                  : 'Choose video',
                              child: FilledButton.tonal(
                                onPressed: _isUploading ? null : _pickVideo,
                                child: Text(
                                  hasValidVideo ? 'Change' : 'Choose',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Description', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  enabled: !_isUploading,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Enter description',
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: defaultOutlineColor,
                        width: borderWidth,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: highContrast ? 3 : 2,
                      ),
                    ),
                  ),
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 24),
                Semantics(
                  button: true,
                  enabled: !_isUploading && hasValidVideo,
                  label: 'Upload video',
                  hint: hasValidVideo
                      ? 'Uploads the selected video'
                      : 'Select a video first',
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: (_isUploading || !hasValidVideo)
                          ? null
                          : _upload,
                      child: _isUploading
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Uploading…'),
                              ],
                            )
                          : const Text('Upload'),
                    ),
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
