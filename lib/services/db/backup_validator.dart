import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

/// Public method to verify backup file in a background isolate.
Future<Map<String, dynamic>> verifyBackupFile(String filePath) async {
  return await Isolate.run(() => _verifyBackup(filePath));
}

/// Core verification logic (runs inside isolate)
Map<String, dynamic> _verifyBackup(String filePath) {
  final errors = <String>[];

  // 1️⃣ Check if file exists
  final file = File(filePath);
  if (!file.existsSync()) {
    return {
      "isValid": false,
      "errors": ["Backup file not found at path: $filePath"]
    };
  }

  // 2️⃣ Read and parse JSON
  Map<String, dynamic>? jsonData;
  try {
    final content = file.readAsStringSync();
    final parsed = jsonDecode(content);
    if (parsed is Map<String, dynamic>) {
      jsonData = parsed;
    } else {
      return {
        "isValid": false,
        "errors": ["Backup file root is not a JSON object."]
      };
    }
  } catch (e) {
    return {
      "isValid": false,
      "errors": ["Invalid JSON format: $e"]
    };
  }

  // 3️⃣ Check for _meta section
  final meta = jsonData["_meta"];
  if (meta == null) {
    errors.add("Missing '_meta' section.");
  } else if (meta is! Map<String, dynamic>) {
    errors.add("'_meta' must be a JSON object.");
  } else {
    // Required meta fields
    const requiredMetaKeys = ["generated_by", "version", "created_at", "note"];
    for (var key in requiredMetaKeys) {
      final val = meta[key];
      if (val == null || val.toString().trim().isEmpty) {
        errors.add("Missing or empty meta field: $key");
      }
    }
  }

  // 4️⃣ Validate each section dynamically (except _meta)
  jsonData.forEach((key, value) {
    if (key == "_meta") return;

    if (value is! List) {
      errors.add("Section '$key' should be a list.");
      return;
    }

    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      if (item is! String) {
        errors.add("Item $i in section '$key' is not a JSON string.");
        continue;
      }
      try {
        jsonDecode(item); // Validate embedded JSON
      } catch (e) {
        errors.add("Corrupted JSON string in section '$key' at index $i: $e");
      }
    }
  });

  // 5️⃣ Version format sanity check
  if (meta is Map<String, dynamic>) {
    final versionStr = meta["version"]?.toString();
    if (versionStr == null ||
        !RegExp(r"^v\d+\.\d+\.\d+\+\d+$").hasMatch(versionStr)) {
      errors.add("Invalid or missing version format in meta: $versionStr");
    }
  }

  return {
    "isValid": errors.isEmpty,
    "errors": errors,
  };
}
