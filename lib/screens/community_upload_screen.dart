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

  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isUploading = false;

  @override
  void dispose() {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool hasValidVideo =
        _selectedFilePath != null && _selectedFilePath!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: hasValidVideo ? colorScheme.secondaryContainer : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: hasValidVideo
                      ? colorScheme.primary
                      : theme.dividerColor,
                ),
              ),
              child: ListTile(
                leading: Icon(
                  hasValidVideo ? Icons.check_circle : Icons.videocam_outlined,
                  color: hasValidVideo
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                title: Text('Video', style: theme.textTheme.titleMedium),
                subtitle: Text(
                  _selectedFileName == null
                      ? 'No video selected'
                      : _selectedFileName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: OutlinedButton(
                  onPressed: _isUploading ? null : _pickVideo,
                  child: Text(hasValidVideo ? 'Change' : 'Choose video'),
                ),
                onTap: _isUploading ? null : _pickVideo,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              enabled: !_isUploading,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Optional',
                border: const OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (_isUploading || !hasValidVideo) ? null : _upload,
                child: _isUploading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('Uploading...'),
                        ],
                      )
                    : const Text('Upload'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
