import 'dart:io';

const needle = 'dart_plugin_registrant.dart';

Future<void> main(List<String> args) async {
  final root = args.isNotEmpty ? Directory(args.first) : Directory.current;
  if (!await root.exists()) {
    stderr.writeln('Root directory does not exist: ${root.path}');
    exitCode = 2;
    return;
  }

  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart')) continue;

    final lines = await _readLinesOrNull(entity);
    if (lines == null) continue;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains(needle)) {
        // grep-like output: path:line:content
        stdout.writeln('${entity.path}:${i + 1}:$line');
      }
    }
  }
}

Future<List<String>?> _readLinesOrNull(File file) async {
  try {
    return await file.readAsLines();
  } on FileSystemException {
    return null;
  } on FormatException {
    return null;
  }
}
