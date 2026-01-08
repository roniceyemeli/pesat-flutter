import 'package:riverpod/riverpod.dart';
import 'dart:io';
import '../services/storage_service.dart';
import '../services/image_picker_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());
final imagePickerServiceProvider = Provider((ref) => ImagePickerService());

final uploadEventImageProvider = FutureProvider.family<String, File>((ref, imageFile) async {
  final storageService = ref.watch(storageServiceProvider);
  return storageService.uploadEventImage(imageFile);
});

final pickImageProvider = FutureProvider<File?>((ref) async {
  final imagePickerService = ref.watch(imagePickerServiceProvider);
  return imagePickerService.pickImage();
});

final pickImageFromCameraProvider = FutureProvider<File?>((ref) async {
  final imagePickerService = ref.watch(imagePickerServiceProvider);
  return imagePickerService.pickImageFromCamera();
});
