import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests runtime permissions only when a feature needs them.
abstract final class PermissionService {
  static Future<bool> ensureCameraAccess(BuildContext context) async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    var status = await Permission.camera.status;
    if (status.isGranted) return true;

    status = await Permission.camera.request();
    if (status.isGranted) return true;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to take product photos.'),
        ),
      );
    }
    return false;
  }

  static Future<bool> ensureSourceAccess(
    BuildContext context,
    ImageSource source,
  ) async {
    if (source == ImageSource.camera) {
      return ensureCameraAccess(context);
    }
    // Gallery uses the system photo picker on modern Android/iOS.
    return true;
  }
}
