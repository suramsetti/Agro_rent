import 'dart:io';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  Future<Map<String, String?>> pickAndUpload({
    required String folder,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // Pick image
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return {'base64': null, 'localPath': null};

      debugPrint('Image selected: ${picked.name}');

      // Convert image to base64 for database storage
      final bytes = await File(picked.path).readAsBytes();
      final base64String = base64Encode(bytes);

      // Return both the base64 string and the actual selected image path
      return {'base64': base64String, 'localPath': picked.path};
    } catch (e) {
      debugPrint('Image selection failed: $e');
      return {'base64': null, 'localPath': null};
    }
  }

  // Helper method to get image from base64 for display
  Image imageFromBase64String(
    String base64String, {
    double? width,
    double? height,
  }) {
    return Image.memory(
      base64Decode(base64String),
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  // Helper method to check if string is base64
  static bool isBase64(String? str) {
    if (str == null || str.isEmpty) return false;
    // Base64 strings are usually long and contain specific characters
    return str.length > 100 &&
        !str.startsWith('http') &&
        !str.startsWith('assets/');
  }

  // Helper method to get default image for machine type
  static String getDefaultMachineImage(String machineName) {
    final lowerName = machineName.toLowerCase();

    if (lowerName.contains('drone') || lowerName.contains('sprayer')) {
      return 'assets/image_529957.jpg'; // Drone image
    } else if (lowerName.contains('john') ||
        lowerName.contains('deere') ||
        lowerName.contains('5050')) {
      return 'assets/image_529fe3.jpg'; // John Deere image
    } else if (lowerName.contains('mahindra') ||
        lowerName.contains('yuvo') ||
        lowerName.contains('tractor')) {
      return 'assets/image_529c1d.jpg'; // Mahindra image
    } else {
      // Default fallback
      return 'assets/image_529c1d.jpg'; // Default to Mahindra
    }
  }

  // Helper method to create appropriate Image widget
  static Widget createImageWidget(
    String? imageUrl, {
    double? width,
    double? height,
    BoxFit? fit,
    String? machineName,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      // Use default image based on machine type if provided, otherwise use default fallback
      if (machineName != null && machineName.isNotEmpty) {
        return Image.asset(
          getDefaultMachineImage(machineName),
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              child: Icon(
                Icons.agriculture,
                size: (width ?? 50) * 0.6,
                color: Colors.grey.shade600,
              ),
            );
          },
        );
      }
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        child: Icon(
          Icons.agriculture,
          size: (width ?? 50) * 0.6,
          color: Colors.grey.shade600,
        ),
      );
    }

    if (isBase64(imageUrl)) {
      try {
        return Image.memory(
          base64Decode(imageUrl),
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              child: Icon(
                Icons.broken_image,
                size: (width ?? 50) * 0.6,
                color: Colors.grey.shade600,
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: Icon(
            Icons.broken_image,
            size: (width ?? 50) * 0.6,
            color: Colors.grey.shade600,
          ),
        );
      }
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            child: Icon(
              Icons.broken_image,
              size: (width ?? 50) * 0.6,
              color: Colors.grey.shade600,
            ),
          );
        },
      );
    } else {
      // Network image (for future use with Firebase)
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            child: Icon(
              Icons.broken_image,
              size: (width ?? 50) * 0.6,
              color: Colors.grey.shade600,
            ),
          );
        },
      );
    }
  }
}
