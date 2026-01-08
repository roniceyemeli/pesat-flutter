import 'package:flutter/material.dart';
import 'dart:io';

class EventImagePicker extends StatefulWidget {
  final Function(File) onImageSelected;

  const EventImagePicker({Key? key, required this.onImageSelected})
      : super(key: key);

  @override
  State<EventImagePicker> createState() => _EventImagePickerState();
}

class _EventImagePickerState extends State<EventImagePicker> {
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            color: const Color(0xFFF9FAFB),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No image selected',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickFromCamera,
                icon: const Icon(Icons.camera),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _pickFromGallery() {
    // Implement image picking logic
  }

  void _pickFromCamera() {
    // Implement camera capture logic
  }
}
