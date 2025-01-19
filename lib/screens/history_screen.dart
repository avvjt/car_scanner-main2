import 'package:card_scanner/models/business_card_model.dart';
import 'package:flutter/material.dart';
import '../services/storage.dart';

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
          child: Row(
            children: [
              // Card Image
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
              // Card Details
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
                    if (card.position.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        card.position,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (card.company.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        card.company,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                    SizedBox(height: 4),
                    Text(
                      'Added: ${_formatDate(DateTime.parse(card.dateTime))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // Delete Button
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.black),
                onPressed: () {
                  _showDeleteConfirmation(context, card);
                },
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
