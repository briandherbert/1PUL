import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_camera/globals.dart';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:intl/intl.dart';


class GCSUploader {
  static String base64ServiceAccountKey = dotenv.env['SERVICE_ACCT_CREDS']!;
  static String bucketName = 'organizer_photos';

  GCSUploader();

  static String getCurrentDateTimeFormatted() {
  final now = DateTime.now();
  final formatter = DateFormat('yyyy_MM_dd_HH_mm_ss');
  return formatter.format(now);
}

  static String uploadImageEventually(PhotoItem photoItem) {
    final filename = 'image_${photoItem.formattedTimestamp}.jpeg';
    
    Future.microtask(() async {
      await uploadImage(await photoItem.getJpegBytes(), filename: filename);
    });

    return '${getGCSPrefix()}$filename';
  }

  static Future<String?> uploadImage(Uint8List? bytes, {String? filename}) async {
    if (bytes == null) {
      throw Exception('No image data to upload.');
    }

    final serviceAccountKey = json.decode(utf8.decode(base64.decode(base64ServiceAccountKey)));

    final accountCredentials = auth.ServiceAccountCredentials.fromJson(serviceAccountKey);
    final scopes = [storage.StorageApi.devstorageFullControlScope];
    final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

    final storageApi = storage.StorageApi(client);
    final media = storage.Media(Stream.value(bytes), bytes.length);

    String formattedDate = getCurrentDateTimeFormatted();

    filename ??= 'image_$formattedDate.jpeg';

    print('upload img filename $filename');
    final object = storage.Object()..name = filename;
    try {
      await storageApi.objects.insert(object, bucketName, uploadMedia: media);
      print('Upload successful.');
      return '${getGCSPrefix()}$filename';
    } catch (e) {
      print('Failed to upload: $e');
    } finally {
      client.close();
    }

    return null;
  }
}
