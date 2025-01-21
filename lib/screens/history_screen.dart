import 'package:card_scanner/models/business_card_model.dart';
import 'package:card_scanner/services/csv_service.dart';
import 'package:flutter/material.dart';
import '../services/storage.dart';
import 'package:card_scanner/models/constants.dart';

import 'dart:io';

import 'detaisl_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  StorageService _service = StorageService();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _getCards();
      });
    });
    super.initState();
  }

  Future<void> _getCards() async {
    cards = await _service.getAllBusinessCards();
    setState(() {});
  }

  List<BusinessCardModel> cards = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Business Cards',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19.0, // Adjust the size as needed
          ),
        ),
        actions: [
          if (cards.isNotEmpty)
            IconButton(
                onPressed: () async {
                  CsvService().exportCSV(cards);
                },
                icon: const Icon(Icons.save_alt)),
        ],
      ),
      body: cards.isEmpty
          ? Center(
              child: Text(
                'No saved business cards',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: cards.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final card = cards[index];
                return _buildCardItem(context, card);
              },
            ),
    );
  }

  Widget _buildCardItem(BuildContext context, BusinessCardModel card) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                businessCard: card,
                imageFile: File(card.imageFilePath),
                isFromHistory: true,
              ),
            ),
          ).then((_) async {
            await _getCards();
            setState(() {});
          });
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Display the card image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(card.imageFilePath),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Display basic card details (name, position, company)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (card.position.isNotEmpty)
                          Text(
                            card.position,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        if (card.company.isNotEmpty)
                          Text(
                            card.company,
                            style: TextStyle(fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.black),
                    onPressed: () {
                      _showDeleteConfirmation(context, card);
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (card.selectedFields.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: card.selectedFields
                      .map(
                        (field) => Chip(
                          label: Text(
                            checkboxDisplayNames[field] ??
                                field, // Use global map
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),
              SizedBox(height: 4),
              Text(
                'Created: ${_formatDate(DateTime.parse(card.dateTime))}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context, BusinessCardModel card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Business Card'),
        content: Text('Are you sure you want to delete this business card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _service.deleteBusinessCard(card);
              Navigator.of(context).pop();
              await _getCards();
              setState(() {});
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
