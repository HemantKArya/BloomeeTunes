import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

typedef _GetPackageNameNative = Int32 Function(Pointer<Uint32>, Pointer<Utf16>);
typedef _GetPackageName = int Function(Pointer<Uint32>, Pointer<Utf16>);

/// How this copy of the app was installed.
abstract final class AppDistribution {
  /// True when running from an MSIX package (Microsoft Store or a sideloaded
  /// .msix). Windows updates those packages itself, so the app must not
  /// offer its own downloads.
  static final bool isPackaged = _detectPackage();

  /// Updates come from the Store, not from GitHub/SourceForge.
  static bool get updatesManagedExternally => isPackaged;

  // Unpackaged processes get APPMODEL_ERROR_NO_PACKAGE (15700) instead.
  static const _errorInsufficientBuffer = 122;

  static bool _detectPackage() {
    if (!Platform.isWindows) return false;
    try {
      final getName = DynamicLibrary.open('kernel32.dll')
          .lookupFunction<_GetPackageNameNative, _GetPackageName>(
              'GetCurrentPackageFullName');
      final length = calloc<Uint32>();
      try {
        // A zero-length buffer only asks whether a package identity exists.
        final result = getName(length, nullptr);
        return result == _errorInsufficientBuffer || result == 0;
      } finally {
        calloc.free(length);
      }
    } catch (_) {
      return false;
    }
  }
}
