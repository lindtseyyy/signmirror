import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/l10n/app_strings_provider.dart';
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
    final strings = ref.read(appStringsProvider);

    try {
      final file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[
          XTypeGroup(
            label: strings.communityUploadVideoSectionLabel,
            extensions: const <String>[
              'mp4',
              'mov',
              'm4v',
              'webm',
              'mkv',
              'avi',
            ],
          ),
        ],
      );

      // User canceled: no-op (no snackbar).
      if (file == null) return false;

      final path = file.path;
      if (!_isUsableLocalPath(path)) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              strings.communityUploadFallbackPickerNoUsablePathError,
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
        SnackBar(content: Text(strings.communityUploadNoPickerPluginError)),
      );
      return false;
    } on PlatformException {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.communityUploadFallbackPickerOpenError)),
      );
      return false;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.communityUploadVideoSelectionGenericError),
        ),
      );
      return false;
    }
  }

  Future<void> _pickVideo() async {
    final strings = ref.read(appStringsProvider);

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
          SnackBar(content: Text(strings.communityUploadPlatformNoPathError)),
        );
        return;
      }

      _setSelectedVideo(path: path!, name: file.name);
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.communityUploadFilePickerOpenError)),
      );
    } on MissingPluginException {
      // Fallback: some targets fail to register `file_picker`.
      await _pickVideoWithFileSelector();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.communityUploadVideoSelectionGenericError),
        ),
      );
    }
  }

  Future<void> _upload() async {
    final strings = ref.read(appStringsProvider);

    final path = _selectedFilePath;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.communityUploadChooseVideoFilePrompt)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.communityUploadSuccessSnackbar)),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.communityUploadFailureSnackbar)),
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

    final strings = ref.watch(appStringsProvider);

    final bool hasValidVideo =
        _selectedFilePath != null && _selectedFilePath!.trim().isNotEmpty;

    final String fileNameLabel =
        _selectedFileName ?? strings.communityUploadNoVideoSelectedLabel;

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
      appBar: AppBar(title: Text(strings.communityUploadScreenTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                const SizedBox(height: 6),
                Text(
                  strings.communityUploadScreenInstructions,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  strings.communityUploadVideoSectionLabel,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Semantics(
                  container: true,
                  button: true,
                  enabled: !_isUploading,
                  label: hasValidVideo
                      ? strings.communityUploadSelectedVideoSemanticLabel
                      : strings.communityUploadChooseVideoSemanticLabel,
                  value: fileNameLabel,
                  hint: _isUploading
                      ? strings.communityUploadInProgressSemanticHint
                      : strings.communityUploadTapToPickVideoSemanticHint,
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
                                        ? strings
                                              .communityUploadVideoSelectedLabel
                                        : strings.communityUploadPickVideoLabel,
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
                                      strings
                                          .communityUploadSupportedFormatsLabel,
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
                                  ? strings
                                        .communityUploadChangeSelectedVideoTooltip
                                  : strings.communityUploadChooseVideoTooltip,
                              child: FilledButton.tonal(
                                onPressed: _isUploading ? null : _pickVideo,
                                child: Text(
                                  hasValidVideo
                                      ? strings.communityUploadChangeButtonLabel
                                      : strings
                                            .communityUploadChooseButtonLabel,
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
                Text(
                  strings.communityUploadDescriptionSectionLabel,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  enabled: !_isUploading,
                  decoration: InputDecoration(
                    labelText: strings.communityUploadDescriptionOptionalLabel,
                    hintText: strings.communityUploadDescriptionHint,
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
                  label: strings.communityUploadVideoButtonSemanticLabel,
                  hint: hasValidVideo
                      ? strings.communityUploadSelectedVideoSemanticHint
                      : strings.communityUploadSelectVideoFirstSemanticHint,
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
                                Text(strings.communityUploadingLabel),
                              ],
                            )
                          : Text(strings.communityUploadButtonLabel),
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
