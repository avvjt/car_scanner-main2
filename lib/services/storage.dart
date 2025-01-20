import 'dart:convert';

import 'package:card_scanner/models/business_card_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String businessCardKey = "business_card_data";
  // Future<String> saveImage(File imageFile) async {
  //   try {
  //     final appDir = await getTemporaryDirectory();
  //     final fileName = 'card_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //     final imagePath = path.join(appDir.path, 'images', fileName);
  //
  //     // Create copy of the image in app directory
  //     await imageFile.copy(imagePath);
  //
  //     return imagePath;
  //   } catch (e) {
  //     print('Error saving image: $e');
  //     throw Exception('Failed to save image');
  //   }
  // }

  Future<String> saveImage(File imageFile) async {
    try {
      // Get the cache directory for your app
      final cacheDir = await getTemporaryDirectory();
      final fileName = 'card_${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Define the target subdirectory 'images'
      final imagesDir = Directory('${cacheDir.path}/images');

      // Check if the 'images' directory exists, if not, create it
      if (!await imagesDir.exists()) {
        await imagesDir.create(
            recursive:
                true); // recursive: true creates parent directories if needed
        print("Created 'images' directory: ${imagesDir.path}");
      }

      // Define the full destination path for the image
      final destinationPath = '${imagesDir.path}/$fileName';
      // Read the source file
      final sourceFile = File(imageFile.path);

      // If the source file exists, copy it to the destination
      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationPath);
        return destinationPath;
      } else {
        print('Source file not found: ${imageFile.path}');
        throw 'Source file not found';
      }
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  Future<void> saveBusinessCard(BusinessCardModel card, File imageFile) async {
    try {
      final imagePath = await saveImage(imageFile);

      final newCard = BusinessCardModel(
        id: const Uuid().v4(),
        name: card.name,
        company: card.company,
        email: card.email,
        phone: card.phone,
        address: card.address,
        website: card.website,
        position: card.position,
        additionalPhones: card.additionalPhones,
        additionalEmails: card.additionalEmails,
        imageFilePath: imagePath,
        dateTime: DateTime.now().toIso8601String(),
        note: card.note,
        specification: card.specification,
        selectedFields: card.selectedFields, // Include selectedFields here
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cardData = jsonEncode(newCard.toJson());
      List<String> ls = prefs.getStringList(businessCardKey) ?? [];
      ls.add(cardData);
      await prefs.setStringList(businessCardKey, ls);
    } catch (e) {
      print('Error saving business card: $e');
      throw Exception('Failed to save business card');
    }
  }

  Future<List<BusinessCardModel>> getAllBusinessCards() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> ls = prefs.getStringList(businessCardKey) ?? [];
      List<BusinessCardModel> list = [];
      for (String a in ls) {
        list.add(BusinessCardModel.fromJson(json.decode(a)));
      }
      return list;
    } catch (e) {
      print('Error getting business cards: $e');
      return [];
    }
  }

  Future<void> deleteBusinessCard(BusinessCardModel card) async {
    try {
      // Delete image file if it exists
      if (card.imageFilePath.isNotEmpty) {
        final imageFile = File(card.imageFilePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
      List<BusinessCardModel> ls = await getAllBusinessCards();
      ls.removeWhere((item) => item.id == card.id);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(
          businessCardKey, businessCardModelListToString(ls));
    } catch (e) {
      print('Error deleting business card: $e');
      throw Exception('Failed to delete business card');
    }
  }

  Future<void> updateBusinessCard(BusinessCardModel newCard) async {
    try {
      List<BusinessCardModel> ls = await getAllBusinessCards();

      final index = ls.indexWhere((item) => item.id == newCard.id);
      ls[index] = newCard;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(
          businessCardKey, businessCardModelListToString(ls));
    } catch (e) {
      throw Exception('Failed to update business card');
    }
  }
}
