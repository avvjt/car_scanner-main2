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
  Map<String, String> fieldPlaceholders = {};
  Map<String, TextEditingController> controllers = {};
  String? editingField; // Keeps track of the currently editing field
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

    editableFields.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
      fieldPlaceholders[key] = value.isEmpty ? 'Not available' : value;
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

      await widget.storageService
          .updateBusinessCard(widget.businessCard, updatedCard);

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
        title: Text(
          'Business Card Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),
        ),
        actions: [
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
      child: Column(
        children: editableFields.keys
            .map((field) => _buildEditableField(field))
            .toList(),
      ),
    );
  }

  Widget _buildEditableField(String field) {
    final isEditing = editingField == field;
    final controller = controllers[field]!;
    final fieldIcon = _getFieldIcon(field);

    return GestureDetector(
      onTap: () {
        setState(() {
          editingField = field;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(fieldIcon, size: 20, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  field,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            isEditing
                ? TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (_) {
                      setState(() {
                        hasChanges = true;
                      });
                    },
                    onSubmitted: (_) {
                      setState(() {
                        editingField = null;
                      });
                    },
                  )
                : Text(
                    controller.text.isEmpty ? 'Not available' : controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: controller.text.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
          ],
        ),
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
