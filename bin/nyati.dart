import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('🦬 Usage: nyati <project_name>');
    exit(1);
  }

  final projectName = args.first;
  final templateRepo = 'https://github.com/IsayaOsward/project_setup.git';
  final tempDir = Directory('.nyati_temp');

  print('🚀 Creating Flutter project: $projectName ...');
  final createResult = await Process.run('flutter', ['create', projectName]);

  stdout.write(createResult.stdout);
  stderr.write(createResult.stderr);

  if (createResult.exitCode != 0) {
    print('❌ Failed to create Flutter project.');
    exit(1);
  }

  print('📦 Cloning Nyati template...');
  if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  final cloneResult = await Process.run('git', [
    'clone',
    '--depth',
    '1',
    templateRepo,
    tempDir.path,
  ]);

  stdout.write(cloneResult.stdout);
  stderr.write(cloneResult.stderr);

  if (cloneResult.exitCode != 0) {
    print('❌ Failed to clone template repository.');
    exit(1);
  }

  // Specify what to copy from the template
  final itemsToCopy = ['lib', 'assets', 'l10n.yaml'];

  print('📂 Copying selected folders/files...');
  for (final item in itemsToCopy) {
    final source = Directory('${tempDir.path}/$item');
    final target = Directory('$projectName/$item');

    if (source.existsSync()) {
      await _copyDirectory(source, target);
      print('  ✅ Copied: $item');
    } else if (File('${tempDir.path}/$item').existsSync()) {
      // handle single files like l10n.yaml
      final sourceFile = File('${tempDir.path}/$item');
      final targetFile = File('$projectName/$item');
      await targetFile.create(recursive: true);
      await sourceFile.copy(targetFile.path);
      print('  ✅ Copied file: $item');
    } else {
      print('  ⚠️  Skipped missing: $item');
    }
  }

  // Cleanup temp directory
  tempDir.deleteSync(recursive: true);

  print('📦 Running flutter pub get...');
  final pubGet = await Process.run('flutter', [
    'pub',
    'get',
  ], workingDirectory: projectName);
  stdout.write(pubGet.stdout);
  stderr.write(pubGet.stderr);

  print(
    '\n✅ ${projectName.toUpperCase()} created successfully using Nyati template!',
  );
  print('📁 Navigate: cd $projectName');
  print('🚀 Run: flutter run');
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  if (!destination.existsSync()) {
    destination.createSync(recursive: true);
  }

  await for (var entity in source.list(recursive: false)) {
    if (entity is Directory) {
      final newDir = Directory(
        '${destination.path}/${entity.uri.pathSegments.last}',
      );
      await _copyDirectory(entity, newDir);
    } else if (entity is File) {
      final newFile = File(
        '${destination.path}/${entity.uri.pathSegments.last}',
      );
      await newFile.create(recursive: true);
      await entity.copy(newFile.path);
    }
  }
}
