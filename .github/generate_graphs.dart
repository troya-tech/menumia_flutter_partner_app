import 'dart:io';

void main() async {
  print('Starting graph generation...');
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('lib directory not found');
    exit(1);
  }

  await for (final entity in libDir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      try {
        await processFile(entity);
      } catch (e) {
        print('Error processing ${entity.path}: $e');
      }
    }
  }
  print('Finished graph generation.');
}

Future<void> processFile(File file) async {
  final content = await file.readAsString();
  final lines = content.split('\n');
  final imports = <String>[];

  for (final line in lines) {
    if (line.trim().startsWith('import ')) {
      // Extract the imported uri
      final match = RegExp(r"import\s+['""]([^'""]+)['""]").firstMatch(line);
      if (match != null) {
        imports.add(match.group(1)!);
      }
    }
  }

  // Normalize path separators to forward slashes for consistent processing
  final normalizedPath = file.path.replaceAll('\\', '/');
  
  // Calculate relative path for doc file
  // normalizedPath looks like .../lib/path/to/file.dart
  // We want path/to/file.dart
  
  if (!normalizedPath.contains('/lib/')) {
    // Maybe relative execution, e.g. lib/main.dart
    // if it starts with lib/, fine
    if (!normalizedPath.startsWith('lib/')) {
       // fallback for unexpected path format
       print('Skipping ${file.path} (unexpected path)');
       return;
    }
  }
  
  final parts = normalizedPath.split('/lib/');
  final relativePath = parts.length > 1 ? parts.last : parts[0]; 
  
  final docRelativePath = 'docs/dependencies/${relativePath.replaceAll('.dart', '_dependency.md')}';
  
  final docFile = File(docRelativePath);
  if (!docFile.parent.existsSync()) {
    await docFile.parent.create(recursive: true);
  }

  final fileName = file.uri.pathSegments.last;
  final graph = generateGraph(fileName, imports, relativePath);
  
  await docFile.writeAsString('''# Dependency Graph: $fileName

Location: `lib/$relativePath`

```mermaid
graph TD
$graph
```
''');
  print('Generated $docRelativePath');
}

String generateGraph(String currentFileName, List<String> imports, String relativePath) {
  final sb = StringBuffer();
  // Sanitize currentFileName for ID
  final currentNodeId = _sanitize(currentFileName);
  final currentLabel = '[${_classify(relativePath)}] $currentFileName';
  
  sb.writeln('    $currentNodeId["$currentLabel"]');
  
  for (final importUri in imports) {
    if (importUri.isEmpty) continue;
    
    String label = '';
    String type = '';
    String name = importUri.split('/').last; 
    
    if (importUri.startsWith('dart:') || 
        importUri.startsWith('package:flutter/') || 
        importUri.startsWith('package:flutter_riverpod') ||
        importUri.startsWith('package:firebase') ||
        importUri.startsWith('package:google_sign_in') ||
        (!importUri.startsWith('package:menumia_flutter_partner_app') && importUri.startsWith('package:'))) {
      type = '[Library]';
      if(importUri.startsWith('dart:')) name = importUri;
      else if(importUri.startsWith('package:')) {
         // simplify package name
         final parts = importUri.substring(8).split('/');
         if (parts.isNotEmpty) name = '${parts[0]}/${parts.last}';
      }
    } else {
       // Internal project import
       // Resolve full path to classify if possible, usually we classify based on the file name or path segments
       // For relative imports, we just look at the import string or name
       
       String analysisPath = importUri;
       if (importUri.startsWith('package:menumia_flutter_partner_app/')) {
          analysisPath = importUri.replaceAll('package:menumia_flutter_partner_app/', '');
       } else {
          // relative import, try to map? 
          // For now just use the name for classification if possible, or keep existing logic
       }
       
       type = '[${_classify(analysisPath)}]';
    }
    
    final importNodeId = _sanitize(name);
    sb.writeln('    $currentNodeId --> $importNodeId["$type $name"]');
  }
  
  return sb.toString();
}

String _sanitize(String name) {
  return name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
}

String _classify(String path) {
  if (path.contains('domain/entities') || path.contains('models')) return 'Entity';
  if (path.contains('domain') && !path.contains('entities')) return 'Domain';
  if (path.contains('infrastructure') || path.contains('data') || path.contains('repositories') || path.contains('dtos')) return 'Infrastructure';
  if (path.contains('application') || path.contains('services') || path.contains('providers') || path.contains('usecases')) return 'Application';
  if (path.contains('pages') || path.contains('widgets') || path.contains('presentation') || path.contains('views')) return 'UI';
  if (path.contains('theme') || path.endsWith('app_colors.dart')) return 'Theme';
  return 'Project';
}
