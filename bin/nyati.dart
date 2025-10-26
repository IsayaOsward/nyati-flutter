import 'dart:io';
import 'package:path/path.dart' as p;

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('🦬 Usage: nyati <project_name>');
    return;
  }

  final projectName = arguments[0];
  final projectPath = p.join(Directory.current.path, projectName);

  print('🚀 Creating Flutter project: $projectName ...');

  // Step 1: Run flutter create
  final result = Process.runSync('flutter', [
    'create',
    projectName,
  ], runInShell: true);
  stdout.write(result.stdout);
  stderr.write(result.stderr);

  // Step 2: Copy template files into new project
  final templatePath = p.join(
    Directory.current.path,
    'template',
  ); // Adjust path if needed
  copyTemplate(templatePath, projectPath);

  print('✅ $projectName created successfully using Nyati template!');
  print('📁 Navigate: cd $projectName');
  print('🚀 Run: flutter run');
}

void copyTemplate(String templatePath, String projectPath) {
  final templateDir = Directory(templatePath);
  final projectDir = Directory(projectPath);

  if (!templateDir.existsSync()) {
    print('❌ Template folder does not exist at $templatePath');
    return;
  }

  if (!projectDir.existsSync()) {
    projectDir.createSync(recursive: true);
  }

  for (var entity in templateDir.listSync(recursive: true)) {
    final relativePath = p.relative(entity.path, from: templatePath);
    final newPath = p.join(projectPath, relativePath);

    if (entity is File) {
      File(newPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(entity.readAsBytesSync());
      print('✅ Copied file: $relativePath');
    } else if (entity is Directory) {
      Directory(newPath).createSync(recursive: true);
      print('✅ Created folder: $relativePath');
    }
  }

  // Ensure assets folder exists with subfolders
  final assetsPath = p.join(projectPath, 'assets');
  Directory(p.join(assetsPath, 'images')).createSync(recursive: true);
  Directory(p.join(assetsPath, 'svg')).createSync(recursive: true);
  print('📂 Created assets/images and assets/svg folders');
}
