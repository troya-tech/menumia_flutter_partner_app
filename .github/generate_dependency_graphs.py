import os
import re
import shutil

def main():
    project_root = os.getcwd()
    lib_dir = os.path.join(project_root, 'lib')
    docs_dir = os.path.join(project_root, 'docs', 'dependencies')
    package_name = 'menumia_flutter_partner_app' # Adjust if needed, or detect from pubspec.yaml

    if not os.path.exists(lib_dir):
        print(f"Error: 'lib' directory not found in {project_root}")
        return

    # Clean existing docs directory
    if os.path.exists(docs_dir):
        print(f"Cleaning existing docs directory: {docs_dir}")
        try:
            shutil.rmtree(docs_dir)
        except Exception as e:
            print(f"Error cleaning docs directory: {e}")
            return

    print("Starting dependency graph generation...")

    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                process_file(file_path, project_root, docs_dir, package_name)

    print("Finished generation.")

def process_file(file_path, project_root, docs_dir, package_name):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return

    imports = []
    # Regex to capture import contents between quotes
    import_pattern = re.compile(r"import\s+['\"]([^'\"]+)['\"]")
    
    for line in content.splitlines():
        line = line.strip()
        if line.startswith('import '):
            match = import_pattern.search(line)
            if match:
                imports.append(match.group(1))

    # Calculate relative paths
    # file_path: .../project/lib/path/to/file.dart
    # relative_from_lib: path/to/file.dart
    
    abs_lib = os.path.join(project_root, 'lib')
    relative_from_lib = os.path.relpath(file_path, abs_lib).replace(os.sep, '/')
    
    # Target doc file path
    # docs/dependencies/path/to/file_dependency.md
    doc_relative_path = relative_from_lib.replace('.dart', '_dependency.md')
    doc_file_path = os.path.join(docs_dir, doc_relative_path)
    
    os.makedirs(os.path.dirname(doc_file_path), exist_ok=True)
    
    file_name = os.path.basename(file_path)
    graph_content = generate_graph(file_name, imports, relative_from_lib, package_name)
    
    markdown_content = f"""# Dependency Graph: {file_name}

Location: `lib/{relative_from_lib}`

```mermaid
graph TD
{graph_content}
```
"""
    
    try:
        with open(doc_file_path, 'w', encoding='utf-8') as f:
            f.write(markdown_content)
        print(f"Generated: docs/dependencies/{doc_relative_path}")
    except Exception as e:
        print(f"Error writing {doc_file_path}: {e}")

def generate_graph(current_file_name, imports, relative_path, package_name):
    lines = []
    
    # Node for current file
    current_node_id = sanitize_id(current_file_name)
    current_type = classify_path(relative_path)
    current_label = f"[{current_type}] {current_file_name}"
    
    lines.append(f'    {current_node_id}["{current_label}"]')
    
    for import_uri in imports:
        if not import_uri:
            continue
            
        import_type = ""
        import_name = ""
        
        # Check if external library or internal
        is_library = False
        
        if import_uri.startswith('dart:'):
            is_library = True
            import_name = import_uri
        elif import_uri.startswith('package:'):
            if import_uri.startswith(f'package:{package_name}/'):
                # Internal absolute import
                is_library = False
                # Remove package prefix to analyze path for classification
                analysis_path = import_uri.replace(f'package:{package_name}/', '')
                import_type = classify_path(analysis_path)
                import_name = import_uri.split('/')[-1]
            else:
                # External package
                is_library = True
                # Simplify name: package:flutter/material.dart -> flutter/material.dart
                parts = import_uri.replace('package:', '').split('/')
                if len(parts) > 1:
                    import_name = f"{parts[0]}/{parts[-1]}"
                else:
                    import_name = parts[0]
        else:
            # Relative import
            is_library = False
            # For relative imports, identifying the full type is harder without resolving the path.
            # We will try to classify based on the file name or best guess, 
            # or ideally resolve the relative path.
            # For simplicity in this script, we'll just classify the filename/import path string
            import_type = classify_path(import_uri) 
            import_name = import_uri.split('/')[-1]

        if is_library:
            import_type = "Library"
            
        import_node_id = sanitize_id(import_name)
        
        # Avoid self-loops if something weird happens, though usually unlikely with this logic
        if import_node_id != current_node_id:
            lines.append(f'    {current_node_id} --> {import_node_id}["[{import_type}] {import_name}"]')
            
    return "\n".join(lines)

def sanitize_id(name):
    # Replace non-alphanumeric chars with underscore
    return re.sub(r'[^a-zA-Z0-9_]', '_', name)

def classify_path(path):
    # Normalize path separator
    path = path.replace('\\', '/')
    
    if 'domain/entities' in path or 'models' in path:
        return 'Entity'
    if 'domain' in path and 'entities' not in path:
        return 'Domain'
    if any(x in path for x in ['infrastructure', 'data', 'repositories', 'dtos', 'repository']):
        return 'Infrastructure'
    if any(x in path for x in ['application', 'services', 'providers', 'usecases', 'facade']):
        return 'Application'
    if any(x in path for x in ['pages', 'widgets', 'presentation', 'views']):
        return 'UI'
    if 'theme' in path or path.endswith('app_colors.dart') or 'utils' in path:
        return 'Theme'
    
    return 'Project'

if __name__ == "__main__":
    main()
