import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../services/camer_service.dart';
import '../services/storage.dart';
import '../services/text_reco.dart';
import '../widegts/camera_overlays.dart';
import 'detaisl_screen.dart';

class CameraScreen extends StatefulWidget {
  final StorageService storageService;

  const CameraScreen({
    Key? key,
    required this.storageService,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}
class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final TextRecognitionService _textRecognitionService =
      TextRecognitionService();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      setState(() {});
    } catch (e) {
      _showErrorDialog('Camera initialization failed: $e');
    }
  }

  Future<void> _captureAndProcess() async {
    if (!_cameraService.isInitialized) return;

    setState(() => _isLoading = true);
    try {
      final imageFile = await _cameraService.captureAndCrop();
      if (imageFile != null) {
        final businessCard =
            await _textRecognitionService.processImage(imageFile);
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(
              businessCard: businessCard,
              imageFile: imageFile,
              isFromHistory: true,
              storageService: widget.storageService,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to process image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_cameraService.isInitialized)
            CameraPreview(_cameraService.controller!)
          else
            Center(child: CircularProgressIndicator()),
          CameraOverlay(),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _captureAndProcess,
                icon: Icon(Icons.camera_alt),
                label: Text('Capture Card'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
