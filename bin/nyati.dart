import 'dart:io';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print(
      '🦬 Usage: nyati <project_name> [--template <branch_name> | -t <branch_name>]',
    );
    exit(1);
  }

  final projectName = arguments.first;

  // 🔍 Parse optional branch name (support both --template and -t)
  String? branchName;
  final templateFlags = ['--template', '-t'];
  for (final flag in templateFlags) {
    final index = arguments.indexOf(flag);
    if (index != -1 && index + 1 < arguments.length) {
      branchName = arguments[index + 1];
      break;
    }
  }

  await createFlutterProject(projectName: projectName, branchName: branchName);
}

Future<void> createFlutterProject({
  required String projectName,
  String? branchName,
}) async {
  print('🚀 Creating Flutter project: $projectName ...');

  // 1️⃣ Create the Flutter project with org name
  final org = 'com.${projectName.toLowerCase()}.app';
  final createResult = await Process.start('flutter', [
    'create',
    '--org',
    org,
    projectName,
  ], runInShell: true);

  await stdout.addStream(createResult.stdout);
  await stderr.addStream(createResult.stderr);

  if (await createResult.exitCode != 0) {
    print('❌ Failed to create Flutter project.');
    exit(1);
  }

  // 2️⃣ Clone the GitHub template
  print('📦 Setting up project template...');
  final tempDir = Directory('${Directory.current.path}/.nyati_temp');

  if (await tempDir.exists()) {
    await tempDir.delete(recursive: true);
  }

  final args = [
    'clone',
    '--depth',
    '1',
    'https://github.com/IsayaOsward/FLUTTER-TEMPLATE.git',
    tempDir.path,
  ];

  // ✅ If user provided a branch (via --template or -t)
  if (branchName != null) {
    args.insertAll(1, ['-b', branchName]);
    print('🌿 Using template branch: $branchName');
  }

  final cloneResult = await Process.run('git', args);

  if (cloneResult.exitCode != 0) {
    print(
      '❌ Failed to configure template: ${cloneResult.stderr}\n'
      '   Check if the provided branch "$branchName" exists.',
    );
    exit(1);
  }

  print('✅ Template configured successfully!');

  // 3️⃣ Copy template folders
  final projectDir = Directory(projectName);
  print('📦 Setting up assets folders...');

  final destination = Directory('${projectDir.path}/');
  final assetsDir = Directory('${destination.path}assets');
  final imagesDir = Directory('${assetsDir.path}/images');
  final svgDir = Directory('${assetsDir.path}/svg');

  await imagesDir.create(recursive: true);
  await svgDir.create(recursive: true);
  print('✅ Created assets/images and assets/svg on project root directory...');

  final foldersToCopy = ['lib'];
  for (final item in foldersToCopy) {
    final source = Directory('${tempDir.path}/$item');
    final destination = Directory(projectDir.path);

    if (await source.exists()) {
      final existingFolder = Directory('${projectDir.path}/$item');
      if (await existingFolder.exists()) {
        print('🗑️  Removing old $item folder...');
        await existingFolder.delete(recursive: true);
      }

      await copyDirectory(source, destination);
      print('✅ Copied: $item');
    } else {
      print('⚠️  Skipped missing: $item');
    }
  }

  // 4️⃣ Add dependencies
  print('📦 Adding dependencies...');
  final dependencies = [
    'flutter_secure_storage',
    'build_runner',
    'flutter_svg',
    'flutter_gen_runner',
    'flutter_localization',
    'go_router',
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

  // 5️⃣ Update pubspec.yaml
  await updatePubspec(projectDir.path);

  // 6️⃣ Run pub get
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

  if (!content.contains('flutter:')) {
    content += '\nflutter:\n';
  }

  if (!content.contains('assets/images/')) {
    content += '''
  assets:
    - assets/images/
    - assets/svg/
''';
  }

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
