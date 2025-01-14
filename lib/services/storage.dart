import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../models/card.dart';


class StorageService {
  static const String boxName = 'business_cards';
  late Box<BusinessCard> _box;

  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();

    // Create images directory if it doesn't exist
    final imagesDir = Directory('${appDir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    await Hive.initFlutter(appDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BusinessCardAdapter());
    }

    _box = await Hive.openBox<BusinessCard>(boxName);
  }

  Future<String> saveImage(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'card_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = path.join(appDir.path, 'images', fileName);

      // Create copy of the image in app directory
      await imageFile.copy(imagePath);

      return imagePath;
    } catch (e) {
      print('Error saving image: $e');
      throw Exception('Failed to save image');
    }
  }

  Future<void> saveBusinessCard(BusinessCard card, File imageFile) async {
    try {
      final imagePath = await saveImage(imageFile);

      final newCard = BusinessCard(
        name: card.name,
        company: card.company,
        email: card.email,
        phone: card.phone,
        address: card.address,
        website: card.website,
        position: card.position,
        additionalPhones: card.additionalPhones,
        additionalEmails: card.additionalEmails,
        imagePath: imagePath,
        dateAdded: DateTime.now(),
      );

      await _box.add(newCard);
    } catch (e) {
      print('Error saving business card: $e');
      throw Exception('Failed to save business card');
    }
  }

  List<BusinessCard> getAllBusinessCards() {
    try {
      return _box.values.toList().reversed.toList();
    } catch (e) {
      print('Error getting business cards: $e');
      return [];
    }
  }

  Future<void> deleteBusinessCard(BusinessCard card) async {
    try {
      // Delete image file if it exists
      if (card.imagePath.isNotEmpty) {
        final imageFile = File(card.imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      // Delete card from Hive
      final index = _box.values.toList().indexOf(card);
      if (index != -1) {
        await _box.deleteAt(index);
      }
    } catch (e) {
      print('Error deleting business card: $e');
      throw Exception('Failed to delete business card');
    }
  }
  Future<void> updateBusinessCard(BusinessCard oldCard, BusinessCard newCard) async {
    final box = Hive.box<BusinessCard>(boxName);
    final index = box.values.toList().indexOf(oldCard);
    if (index != -1) {
      await box.putAt(index, newCard);
    }
  }
}