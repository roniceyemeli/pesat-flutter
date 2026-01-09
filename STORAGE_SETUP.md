# Supabase Storage Bucket Setup Guide

## Overview

This guide explains how to set up storage buckets for your Flutter Event Management App to store user profile images and event images.

## Required Buckets

### 1. **event-images** Bucket

- **Purpose**: Store event thumbnails and full images
- **Access**: Public (users can view images without authentication)
- **File Size Limit**: 5MB recommended
- **Formats**: JPEG, PNG, WebP

### 2. **profile-images** Bucket

- **Purpose**: Store user profile pictures
- **Access**: Public (users can view profile pictures)
- **File Size Limit**: 2MB recommended
- **Formats**: JPEG, PNG

---

## Setup Instructions

### Step 1: Create event-images Bucket

1. Go to **Storage** in Supabase dashboard
2. Click **Create a new bucket**
3. Fill in the form:
   - **Bucket name**: `event-images`
   - **Visibility**: Public
4. Click **Create bucket**

### Step 2: Configure RLS Policy for event-images

1. Click **event-images** bucket
2. Click **Policies** tab
3. Click **New Policy** → **Get started**
4. Select **Policy Templates** → **For public buckets**
5. Leave defaults and click **Review**
6. Click **Save policy**

This allows:

- ✅ Public read access to images
- ✅ Authenticated users can upload to the bucket
- ✅ Users can only delete their own images

### Step 3: Create profile-images Bucket

1. Click **Create a new bucket**
2. Fill in the form:
   - **Bucket name**: `profile-images`
   - **Visibility**: Public
3. Click **Create bucket**

### Step 4: Configure RLS Policy for profile-images

1. Click **profile-images** bucket
2. Click **Policies** tab
3. Click **New Policy** → **Get started**
4. Select **Policy Templates** → **For public buckets**
5. Click **Review** → **Save policy**

---

## Storage Paths

### Event Images

```
event-images/
├── {event_id}/
│   ├── thumbnail.jpg
│   ├── full.jpg
│   └── gallery/
│       ├── image1.jpg
│       ├── image2.jpg
│       └── ...
```

### Profile Images

```
profile-images/
├── {user_id}/
│   └── profile.jpg
```

---

## Integration with Flutter App

### Upload Event Image

```dart
// In EventService
Future<String> uploadEventImage(
  File imageFile,
  String eventId,
) async {
  try {
    final fileName = 'full_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '$eventId/$fileName';

    await _supabase.storage
        .from('event-images')
        .upload(filePath, imageFile);

    // Get public URL
    final url = _supabase.storage
        .from('event-images')
        .getPublicUrl(filePath);

    return url;
  } catch (e) {
    print('Error uploading event image: $e');
    rethrow;
  }
}
```

### Upload Profile Image

```dart
// In AuthService
Future<String> uploadProfileImage(
  File imageFile,
  String userId,
) async {
  try {
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '$userId/$fileName';

    await _supabase.storage
        .from('profile-images')
        .upload(filePath, imageFile);

    // Get public URL
    final url = _supabase.storage
        .from('profile-images')
        .getPublicUrl(filePath);

    return url;
  } catch (e) {
    print('Error uploading profile image: $e');
    rethrow;
  }
}
```

### Download Image

```dart
// Images are stored as public URLs, so just use Image.network()
Image.network(
  profileImageUrl,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported),
    );
  },
)
```

---

## File Naming Convention

### Best Practices

1. **Use unique identifiers** in file names
2. **Include timestamps** to avoid overwrites
3. **Use lowercase** for consistency
4. **Include file extension** for proper MIME type detection

### Examples

- ✅ `event-thumbnail_1704067200000.jpg`
- ✅ `profile_avatar_1704067200000.png`
- ✅ `event_full_image_1704067200000.jpg`

### Bad Examples

- ❌ `image.jpg` (too generic, will overwrite)
- ❌ `IMG_001.PNG` (inconsistent casing)
- ❌ `photo` (missing extension)

---

## Image Optimization

### Recommended Image Sizes

| Purpose          | Max Size    | Format | Quality |
| ---------------- | ----------- | ------ | ------- |
| Profile Avatar   | 500x500 px  | JPEG   | 85%     |
| Event Thumbnail  | 400x250 px  | JPEG   | 80%     |
| Event Full Image | 1200x800 px | JPEG   | 85%     |
| Event Gallery    | 800x600 px  | JPEG   | 80%     |

### Dart Image Compression Example

```dart
import 'package:image/image.dart' as img;

Future<File> compressImage(File imageFile) async {
  final image = img.decodeImage(imageFile.readAsBytesSync());
  if (image == null) throw Exception('Failed to decode image');

  // Resize to max width of 1200
  final resized = img.copyResize(image, width: 1200);

  // Compress JPEG quality
  final compressed = img.encodeJpg(resized, quality: 85);

  // Save compressed version
  return File(imageFile.path)..writeAsBytesSync(compressed);
}
```

---

## Bucket RLS Policies (Advanced)

### Allow Public Read, Authenticated Upload

```sql
-- Allow public read
CREATE POLICY "Public read for event images"
ON storage.objects
FOR SELECT
USING (bucket_id = 'event-images');

-- Allow authenticated upload to own folder
CREATE POLICY "Authenticated users can upload event images"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'event-images' AND
  auth.role() = 'authenticated'
);

-- Allow users to delete their own files
CREATE POLICY "Users can delete their own event images"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'event-images' AND
  owner = auth.uid()
);
```

---

## Security Considerations

1. **Validate file uploads** in Flutter before sending
2. **Check MIME type** to prevent malicious uploads
3. **Limit file size** (2-5MB max)
4. **Use secure URLs** with signatures if needed
5. **Delete old images** when users update their profile/event
6. **Scan for viruses** if handling user uploads (optional)

---

## Cleanup Old Images

When a user uploads a new image, delete the old one:

```dart
Future<void> deleteOldImage(String imageUrl) async {
  try {
    // Extract file path from URL
    // URL format: https://xxxx.supabase.co/storage/v1/object/public/event-images/{path}
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;
    final bucketIndex = pathSegments.indexOf('event-images');
    final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

    await _supabase.storage
        .from('event-images')
        .remove([filePath]);
  } catch (e) {
    print('Error deleting image: $e');
    // Continue without throwing - old image cleanup not critical
  }
}
```

---

## Testing

### Test Upload in Supabase Dashboard

1. Go to **Storage** → **event-images**
2. Click **Upload file**
3. Select an image from your computer
4. Verify it appears in the bucket
5. Click the file → **Copy URL**
6. Open URL in browser to verify it's publicly accessible

### Test from Flutter App

```dart
// Add this to your test
void main() {
  testWidgets('Upload event image', (WidgetTester tester) async {
    // Create test image file
    final testImage = File('test/fixtures/test_image.jpg');

    // Upload
    final url = await eventService.uploadEventImage(testImage, 'test-event-id');

    // Verify URL is valid
    expect(url, isNotEmpty);
    expect(url, contains('event-images'));
    expect(url, contains('test-event-id'));
  });
}
```

---

## Troubleshooting

### "403 Forbidden" when uploading

- ✅ Check RLS policies are set to "For public buckets"
- ✅ Verify user is authenticated
- ✅ Check bucket name is spelled correctly

### "404 Not Found" when accessing image

- ✅ Verify image was successfully uploaded
- ✅ Check file path in URL matches storage structure
- ✅ Verify bucket visibility is "Public"

### Images not loading in app

- ✅ Check Image.network() has error handling
- ✅ Verify URL is correct using browser
- ✅ Check network permissions in AndroidManifest.xml
- ✅ Verify CORS settings if loading cross-domain

### File size too large

- ✅ Implement image compression before upload
- ✅ Reduce image dimensions (max 1200x800)
- ✅ Decrease JPEG quality (80-85%)

---

## Next Steps

1. ✅ Create both buckets in Supabase Storage
2. ✅ Configure RLS policies for public access
3. ✅ Test upload and download in dashboard
4. ✅ Integrate storage service into Flutter app
5. ✅ Test end-to-end image upload/download
6. ✅ Implement image compression (optional but recommended)

---

Generated: 2024
For: Flutter Event Management App
