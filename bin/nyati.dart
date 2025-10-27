import 'dart:io';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('🦬 Usage: nyati <project_name>');
    exit(1);
  }

  final projectName = arguments.first;
  await createFlutterProject(projectName);
}

Future<void> createFlutterProject(String projectName) async {
  print('🚀 Creating Flutter project: $projectName ...');

  // 1️⃣ Create the Flutter project
  final createResult = await Process.start('flutter', [
    'create',
    projectName,
  ], runInShell: true);

  await stdout.addStream(createResult.stdout);
  await stderr.addStream(createResult.stderr);

  if (await createResult.exitCode != 0) {
    print('❌ Failed to create Flutter project.');
    exit(1);
  }

  // 2️⃣ Clone the GitHub template
  print('📦 Cloning Nyati template from GitHub...');
  final tempDir = Directory('${Directory.current.path}/.nyati_temp');

  if (await tempDir.exists()) {
    await tempDir.delete(recursive: true);
  }

  final cloneResult = await Process.run('git', [
    'clone',
    '--depth',
    '1',
    'https://github.com/IsayaOsward/project_setup.git',
    tempDir.path,
  ]);

  if (cloneResult.exitCode != 0) {
    print('❌ Failed to clone template: ${cloneResult.stderr}');
    exit(1);
  }

  print('✅ Template cloned successfully!');

  // 3️⃣ Copy template files/folders into the new project
  final projectDir = Directory(projectName);

  final foldersToCopy = ['lib', 'assets', 'l10n.yaml', 'analysis_options.yaml'];
  for (final item in foldersToCopy) {
    final source = Directory('${tempDir.path}/$item');
    final destination = Directory('${projectDir.path}/$item');

    if (await source.exists()) {
      await copyDirectory(source, destination);
      print('✅ Copied: $item');
    } else {
      print('⚠️  Skipped missing: $item');
    }
  }

  // 4️⃣ Add dependencies using flutter pub add
  print('📦 Adding dependencies...');

  final dependencies = [
    'flutter_secure_storage',
    'build_runner',
    'flutter_svg',
    'flutter_gen_runner',
  ];

  for (final dep in dependencies) {
    final result = await Process.run(
      'flutter',
      ['pub', 'add', dep],
      workingDirectory: projectDir.path,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      print('⚠️ Failed to add $dep: ${result.stderr}');
    } else {
      print('✅ Added $dep');
    }
  }

  // 5️⃣ Update pubspec.yaml for assets and flutter_gen
  await updatePubspec(projectDir.path);

  // 6️⃣ Run flutter pub get
  print('📦 Running flutter pub get...');
  final pubGet = await Process.run(
    'flutter',
    ['pub', 'get'],
    workingDirectory: projectDir.path,
    runInShell: true,
  );
  stdout.write(pubGet.stdout);
  stderr.write(pubGet.stderr);

  // 7️⃣ Clean up temporary files
  await tempDir.delete(recursive: true);

  print('\n✅ $projectName created successfully using Nyati template!');
  print('📁 Navigate: cd $projectName');
  print('🚀 Run: flutter run');
}

Future<void> copyDirectory(Directory source, Directory destination) async {
  if (!(await destination.exists())) {
    await destination.create(recursive: true);
  }

  await for (final entity in source.list(recursive: false)) {
    if (entity is File) {
      final newFile = File(
        '${destination.path}/${entity.uri.pathSegments.last}',
      );
      await newFile.writeAsBytes(await entity.readAsBytes());
    } else if (entity is Directory) {
      final newDir = Directory(
        '${destination.path}/${entity.uri.pathSegments.last}',
      );
      await copyDirectory(entity, newDir);
    }
  }
}

Future<void> updatePubspec(String projectPath) async {
  final pubspec = File('$projectPath/pubspec.yaml');
  if (!await pubspec.exists()) {
    print('⚠️ pubspec.yaml not found — skipping update.');
    return;
  }

  var content = await pubspec.readAsString();

  // Ensure flutter: section exists
  if (!content.contains('flutter:')) {
    content += '\nflutter:\n';
  }

  // Add assets section
  if (!content.contains('assets/images/')) {
    content += '''
  assets:
    - assets/images/
    - assets/svg/
''';
  }

  // Add flutter_gen config (without specifying output)
  if (!content.contains('flutter_gen:')) {
    content += '''
flutter_gen:
  integrations:
    flutter_svg: true
''';
  }

  await pubspec.writeAsString(content);
  print('📝 pubspec.yaml updated with assets and flutter_gen configuration.');
}
