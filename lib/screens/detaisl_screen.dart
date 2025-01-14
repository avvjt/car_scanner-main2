import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/card.dart';
import 'dart:io';

import '../services/storage.dart';

class DetailsScreen extends StatefulWidget {
  final BusinessCard businessCard;
  final File imageFile;
  final bool isFromHistory;
  final StorageService storageService;

  const DetailsScreen({
    Key? key,
    required this.businessCard,
    required this.imageFile,
    this.isFromHistory = false,
    required this.storageService,
  }) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Map<String, String> editableFields;
  Map<String, bool> editingStates = {};
  Map<String, TextEditingController> controllers = {};
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    editableFields = {
      'Name': widget.businessCard.name,
      'Position': widget.businessCard.position,
      'Company': widget.businessCard.company,
      'Email': widget.businessCard.email,
      'Phone': widget.businessCard.phone,
      'Website': widget.businessCard.website,
      'Address': widget.businessCard.address,
    };

    // Initialize controllers for each field
    editableFields.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
      editingStates[key] = false;
    });
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (!hasChanges) return;

    try {
      final updatedCard = BusinessCard(
        name: controllers['Name']!.text,
        position: controllers['Position']!.text,
        company: controllers['Company']!.text,
        email: controllers['Email']!.text,
        phone: controllers['Phone']!.text,
        website: controllers['Website']!.text,
        address: controllers['Address']!.text,
        additionalPhones: widget.businessCard.additionalPhones,
        additionalEmails: widget.businessCard.additionalEmails,
        imagePath: widget.businessCard.imagePath,
        dateAdded: widget.businessCard.dateAdded,
      );

      await widget.storageService.updateBusinessCard(widget.businessCard, updatedCard);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Changes saved successfully')),
      );

      setState(() {
        hasChanges = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Card Details'),
        actions: [
         // if (!widget.isFromHistory)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                try {
                  await widget.storageService.saveBusinessCard(
                    widget.businessCard,
                    widget.imageFile,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Business card saved successfully')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save business card')),
                  );
                }
              },
            ),
          if (hasChanges)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: saveChanges,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageSection(),
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          widget.imageFile,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: editableFields.keys.map((field) => _buildEditableField(field)).toList(),
      ),
    );
  }

  Widget _buildEditableField(String field) {
    final bool isEditing = editingStates[field] ?? false;
    final controller = controllers[field]!;
    final IconData fieldIcon = _getFieldIcon(field);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(fieldIcon, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                field,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: isEditing
                    ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      hasChanges = true;
                    });
                  },
                )
                    : Text(
                  controller.text.isEmpty ? 'Not available' : controller.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.text.isEmpty ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  size: 20,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    editingStates[field] = !isEditing;
                    if (!isEditing) {
                      // If starting to edit, do nothing
                    } else {
                      // If finishing edit, update the field
                      editableFields[field] = controller.text;
                      hasChanges = true;
                    }
                  });
                },
              ),
              if (controller.text.isNotEmpty && !isEditing)
                IconButton(
                  icon: Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: controller.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getFieldIcon(String field) {
    switch (field) {
      case 'Name':
        return Icons.person;
      case 'Position':
        return Icons.work;
      case 'Company':
        return Icons.business;
      case 'Email':
        return Icons.email;
      case 'Phone':
        return Icons.phone;
      case 'Website':
        return Icons.language;
      case 'Address':
        return Icons.location_on;
      default:
        return Icons.info;
    }
  }
}