import 'package:flutter/material.dart';
import 'package:flutter_event_app/data/providers/image_upload_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class EventImagePicker extends ConsumerStatefulWidget {
  final Function(File) onImageSelected;

  const EventImagePicker({Key? key, required this.onImageSelected})
      : super(key: key);

  @override
  ConsumerState<EventImagePicker> createState() => _EventImagePickerState();
}

class _EventImagePickerState extends ConsumerState<EventImagePicker> {
  File? _selectedImage;
  bool _isLoading = false;

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
                onPressed: _isLoading ? null : _pickFromGallery,
                icon: const Icon(Icons.photo),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickFromCamera,
                icon: const Icon(Icons.camera),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final imageFile = await ref.read(pickImageProvider.future);
      if (imageFile != null) {
        setState(() => _selectedImage = imageFile);
        widget.onImageSelected(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromCamera() async {
    setState(() => _isLoading = true);
    try {
      final imageFile = await ref.read(pickImageFromCameraProvider.future);
      if (imageFile != null) {
        setState(() => _selectedImage = imageFile);
        widget.onImageSelected(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
