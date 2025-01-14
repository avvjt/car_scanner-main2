import 'package:flutter/material.dart';
import '../models/card.dart';
import '../services/storage.dart';

import 'dart:io';

import 'detaisl_screen.dart';

class HistoryScreen extends StatelessWidget {
  final StorageService storageService;

  const HistoryScreen({Key? key, required this.storageService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cards = storageService.getAllBusinessCards();

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Business Cards'),
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

  Widget _buildCardItem(BuildContext context, BusinessCard card) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                businessCard: card,
                imageFile: File(card.imagePath),
                isFromHistory: true,
                storageService: storageService,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Card Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(card.imagePath),
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
                      'Added: ${_formatDate(card.dateAdded)}',
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
                icon: Icon(Icons.delete_outline, color: Colors.red),
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

  void _showDeleteConfirmation(BuildContext context, BusinessCard card) {
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
              await storageService.deleteBusinessCard(card);
              Navigator.pop(context); // Close dialog
              // Refresh the screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(
                    storageService: storageService,
                  ),
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}