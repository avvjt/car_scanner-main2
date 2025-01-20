import 'package:card_scanner/models/business_card_model.dart';
import 'package:card_scanner/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class DetailsScreen extends StatefulWidget {
  final BusinessCardModel businessCard;
  final File imageFile;
  final bool isFromHistory;

  const DetailsScreen({
    Key? key,
    required this.imageFile,
    this.isFromHistory = false,
    required this.businessCard,
  }) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Map<String, String> editableFields;
  late Map<String, bool> checkboxValues;

  // Map for custom checkbox display names
  Map<String, String> checkboxDisplayNames = {
    'Name': 'Turning',
    'Position': 'Milling',
    'Company': 'Boring',
    'Email': 'Threading',
    'Phone': 'MBU',
    'Website': 'EBB',
    'Address': 'Boring Kit',
    'Note': 'Holder Kit',
    'Specification': 'Facing Head Kit',
  };

  Map<String, String> fieldPlaceholders = {};
  Map<String, TextEditingController> controllers = {};
  String? editingField; // Keeps track of the currently editing field
  bool hasChanges = true;
  StorageService _service = StorageService();

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
      "Note": widget.businessCard.note,
      "Specification": widget.businessCard.specification,
    };

    checkboxValues = {
      for (var key in editableFields.keys)
        key: widget.businessCard.selectedFields.contains(key),
    };

    editableFields.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
      fieldPlaceholders[key] = value.isEmpty ? 'Not available' : value;
    });

    initData();
  }

  initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (widget.isFromHistory) {
          hasChanges = false;
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (!hasChanges) return;

    final selectedFields = checkboxValues.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    try {
      final updatedCard = BusinessCardModel(
        id: widget.businessCard.id,
        name: controllers['Name']!.text,
        position: controllers['Position']!.text,
        company: controllers['Company']!.text,
        email: controllers['Email']!.text,
        phone: controllers['Phone']!.text,
        website: controllers['Website']!.text,
        address: controllers['Address']!.text,
        additionalPhones: widget.businessCard.additionalPhones ?? [],
        additionalEmails: widget.businessCard.additionalEmails ?? [],
        imageFilePath:
            widget.isFromHistory ? widget.businessCard.imageFilePath ?? '' : "",
        dateTime: DateTime.now().toIso8601String(),
        note: controllers["Note"]!.text,
        specification: controllers["Specification"]!.text,

        selectedFields: selectedFields, // Save selected fields
      );

      if (widget.isFromHistory) {
        await _service.updateBusinessCard(updatedCard);
      } else {
        await _service.saveBusinessCard(updatedCard, widget.imageFile);
      }
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
            _buildCheckboxSection(),
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

  Widget _buildCheckboxSection() {
    return Card(
      elevation: 4.0, // Elevation for shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Fields',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Column(
              children: checkboxValues.keys.map((key) {
                return CheckboxListTile(
                  title: Text(
                    checkboxDisplayNames[key] ?? key,
                  ),
                  value: checkboxValues[key],
                  onChanged: (value) {
                    setState(() {
                      checkboxValues[key] = value ?? false;
                    });
                  },
                );
              }).toList(),
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
      case 'Note':
        return Icons.note;
      default:
        return Icons.info;
    }
  }
}
