import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) async {
  final logger = Logger();
  
  logger.info('🔍 Scanning for Flutter examples...');
  
  // Get the root directory (tools/generate_ide_config is where this script runs from)
  final rootDir = Directory.current.path;
  final packagesDir = p.join(rootDir, 'packages');
  
  logger.detail('Root directory: $rootDir');
  logger.detail('Packages directory: $packagesDir');
  
  final examples = <String>[];
  
  try {
    final packagesFolder = Directory(packagesDir);
    
    if (!packagesFolder.existsSync()) {
      logger.err('Packages directory not found at $packagesDir');
      exit(1);
    }
    
    // Scan for example directories
    await for (final packageDir in packagesFolder.list(followLinks: false)) {
      if (packageDir is Directory) {
        final exampleDir = Directory(p.join(packageDir.path, 'example'));
        
        if (exampleDir.existsSync()) {
          final pubspecPath = p.join(exampleDir.path, 'pubspec.yaml');
          final pubspecFile = File(pubspecPath);
          
          if (pubspecFile.existsSync()) {
            final relativePath = p.relative(exampleDir.path, from: rootDir);
            examples.add(relativePath);
            logger.success('Found example: $relativePath');
          }
        }
      }
    }
  } catch (e) {
    logger.err('Error scanning for examples: $e');
    exit(1);
  }
  
  if (examples.isEmpty) {
    logger.warn('No examples found in packages/');
    exit(0);
  }
  
  logger.info('📊 Found ${examples.length} example(s):');
  for (final example in examples) {
    logger.detail('  • $example');
  }
  
  // Generate IDE run configurations
  try {
    await _generateIDEConfigurations(examples, logger);
  } catch (e) {
    logger.err('Error generating IDE configurations: $e');
    exit(1);
  }
  
  logger.info('✅ IDE configurations generated successfully!');
}

Future<void> _generateIDEConfigurations(List<String> examples, Logger logger) async {
  logger.info('📝 Generating IDE run configurations...');
  
  final vscodeDir = Directory('.vscode');
  if (!vscodeDir.existsSync()) {
    vscodeDir.createSync(recursive: true);
    logger.detail('Created .vscode directory');
  }
  
  // Generate VS Code launch configurations
  final launchConfig = _generateLaunchConfig(examples);
  final launchFile = File(p.join('.vscode', 'launch.json'));
  
  await launchFile.writeAsString(launchConfig);
  logger.success('Generated VS Code launch configuration');
  logger.detail('File: ${launchFile.path}');
  
  // Generate tasks configuration
  final tasksConfig = _generateTasksConfig(examples);
  final tasksFile = File(p.join('.vscode', 'tasks.json'));
  
  await tasksFile.writeAsString(tasksConfig);
  logger.success('Generated VS Code tasks configuration');
  logger.detail('File: ${tasksFile.path}');
}

String _generateLaunchConfig(List<String> examples) {
  final configurations = <Map<String, dynamic>>[];
  
  for (final example in examples) {
    final exampleName = p.basename(p.dirname(example));
    configurations.add({
      'name': '$exampleName (example)',
      'cwd': example,
      'request': 'launch',
      'type': 'dart',
      'console': 'debugConsole',
      'args': [],
      'flutterMode': 'debug',
    });
  }
  
  final config = {
    'version': '0.2.0',
    'configurations': configurations,
  };
  
  return _prettyJsonEncode(config);
}

String _generateTasksConfig(List<String> examples) {
  final tasks = <Map<String, dynamic>>[];
  
  for (final example in examples) {
    final exampleName = p.basename(p.dirname(example));
    
    // pub get task
    tasks.add({
      'label': 'pub get: $exampleName',
      'type': 'shell',
      'command': 'flutter',
      'args': ['pub', 'get'],
      'options': {
        'cwd': example,
      },
      'group': {
        'kind': 'build',
        'isDefault': false,
      },
      'problemMatcher': [],
    });
    
    // flutter run task
    tasks.add({
      'label': 'flutter run: $exampleName',
      'type': 'shell',
      'command': 'flutter',
      'args': ['run'],
      'options': {
        'cwd': example,
      },
      'isBackground': true,
      'group': {
        'kind': 'build',
        'isDefault': false,
      },
      'problemMatcher': [],
    });
  }
  
  final config = {
    'version': '2.0.0',
    'tasks': tasks,
  };
  
  return _prettyJsonEncode(config);
}

String _prettyJsonEncode(Map<String, dynamic> json) {
  final buffer = StringBuffer();
  _encodeJson(json, buffer, 0);
  return buffer.toString();
}

void _encodeJson(dynamic value, StringBuffer buffer, int indent) {
  final spaces = '  ' * indent;
  final nextSpaces = '  ' * (indent + 1);
  
  if (value is Map) {
    buffer.write('{\n');
    final entries = value.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('$nextSpaces"${entry.key}": ');
      _encodeJson(entry.value, buffer, indent + 1);
      if (i < entries.length - 1) {
        buffer.write(',');
      }
      buffer.write('\n');
    }
    buffer.write('$spaces}');
  } else if (value is List) {
    buffer.write('[\n');
    for (int i = 0; i < value.length; i++) {
      buffer.write(nextSpaces);
      _encodeJson(value[i], buffer, indent + 1);
      if (i < value.length - 1) {
        buffer.write(',');
      }
      buffer.write('\n');
    }
    buffer.write('$spaces]');
  } else if (value is String) {
    buffer.write('"${value.replaceAll('"', '\\"')}"');
  } else if (value is bool) {
    buffer.write(value ? 'true' : 'false');
  } else if (value is num) {
    buffer.write(value);
  } else if (value == null) {
    buffer.write('null');
  } else {
    buffer.write('"$value"');
  }
}
