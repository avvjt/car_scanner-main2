import 'package:card_scanner/models/business_card_model.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

class TextRecognitionService {
// In your text recognition service
  Future<BusinessCardModel> processImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();

      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

      // For debugging
      print('Recognized text: ${recognizedText.text}');

      final businessCard = BusinessCardModel.fromText(recognizedText.text);

      // For debugging
      print('Parsed business card: $businessCard');

      return businessCard;
    } catch (e) {
      print('Error processing image: $e');
      rethrow;
    }
  }
}