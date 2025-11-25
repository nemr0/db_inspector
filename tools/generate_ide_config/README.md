# Generate IDE Config

A Dart tool that automatically generates IDE run configurations for all Flutter examples found in the `packages/` directory.

## Features

- 🔍 Scans all packages for example projects
- 📝 Generates VS Code launch configurations
- ⚙️ Generates VS Code tasks for building and running examples
- 🎯 Uses `mason_logger` for detailed logging

## Usage

Run the tool from the repository root:

```bash
dart tools/generate_ide_config/bin/generate_ide_config.dart
```

Or using pub:

```bash
cd tools/generate_ide_config
dart pub run bin/generate_ide_config.dart
```

## Output

The tool generates the following files in the `.vscode/` directory:

- **`launch.json`** - Debug launch configurations for each example
- **`tasks.json`** - Build and run tasks for each example

## Example Output

For each example found, you'll see:

```
✅ Found example: packages/flutter_db_inspector/example
📊 Found 1 example(s):
   • packages/flutter_db_inspector/example
📝 Generating IDE run configurations...
✅ Generated VS Code launch configuration
✅ Generated VS Code tasks configuration
✅ IDE configurations generated successfully!
```

## Dependencies

- `path: ^1.8.0` - Path manipulation utilities
- `mason_logger: ^0.3.3` - CLI logging
