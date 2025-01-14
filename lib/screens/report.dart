import 'package:card_scanner/screens/camer_screen.dart';
import 'package:flutter/material.dart';

import '../services/storage.dart';

class ReportScreen extends StatefulWidget {
  final StorageService storageService;
  const ReportScreen({Key? key, required this.storageService}) : super(key: key);
  @override
  _ReportScreenState createState() => _ReportScreenState();
}
class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Align(
          alignment: Alignment.topLeft, // Centers the title
          child: Text(
            "Add Participant",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Options Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.all(16),
              children: [
                _buildGridOption(
                  context,
                  icon: Icons.camera_alt,
                  label: "Scan business card",
                  onTap: () {
                    // Navigate directly to CameraScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraScreen(storageService: widget.storageService)),
                    );
                  },
                ),
                _buildGridOption(
                  context,
                  icon: Icons.credit_card,
                  label: "Scan NFC tag",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Scan NFC feature coming soon")),
                    );
                  },
                ),
                _buildGridOption(
                  context,
                  icon: Icons.qr_code_scanner,
                  label: "Scan QR code or badge",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Scan QR code feature coming soon")),
                    );
                  },
                ),
                _buildGridOption(
                  context,
                  icon: Icons.edit,
                  label: "Add manually",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Working on that...")),
                    );
                  },
                ),
                _buildGridOption(
                  context,
                  icon: Icons.linked_camera,
                  label: "LinkedIn",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("LinkedIn API Scraping on progress")),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person_add, size: 40, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add at least one participant",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "At least one participant is required to export this report. Add one by choosing one of the options above.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridOption(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: InkWell(
        onTap: onTap, // This adds the clickable effect with ripple
        borderRadius:
            BorderRadius.circular(12), // Optional: smooth ripple effect
        child: Card(
          color: Colors.white,
          elevation: 8, // Adjust elevation for shadow intensity
          shadowColor: Colors.black.withOpacity(0.6), // Customize shadow color
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Rounded corners for the card
          ),
          child: Padding(
            padding: const EdgeInsets.all(12), // Padding inside the card
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  child: Icon(icon, size: 30, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
