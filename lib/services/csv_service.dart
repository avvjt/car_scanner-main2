import 'package:card_scanner/models/business_card_model.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class CsvService {
  String convertListToCSV(List<BusinessCardModel> list) {
    List<List<dynamic>> rows = [];

    // Add headers
    // Add headers (based on the BusinessCardModel fields)
    rows.add([
      'Name',
      'Position',
      'Company',
      'Email',
      'Phone',
      'Website',
      'Address',
      'Additional Phones',
      'Additional Emails',
      'Note'
          'Specification'
    ]);

    // Add each business card as a row
    for (var card in list) {
      rows.add([
        card.name,
        card.position,
        card.company,
        card.email,
        card.phone,
        card.website,
        card.address,
        card.additionalPhones
            .join('; '), // Join multiple phones with a separator
        card.additionalEmails
            .join('; '), // Join multiple emails with a separator
        card.note,
        card.specification,
      ]);
    }

    // Convert rows to CSV string
    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }

  Future<void> exportCSV(List<BusinessCardModel> list) async {
    // Request storage permission if needed
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      String csvData = convertListToCSV(list);

      // Get the directory to store the file
      // For Android, get the Downloads directory
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory(
            '/storage/emulated/0/Download'); // Access the Downloads directory directly.
      }

      // For iOS, it's tricky as iOS apps do not have direct access to the downloads folder
      // We will save it in the app's documents directory or another accessible directory
      if (Platform.isIOS) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }
      String filePath = "";
      if (downloadsDirectory != null) {
        filePath =
            '${downloadsDirectory.path}/business_data_${DateTime.now().microsecondsSinceEpoch}.csv';
      } else {
        Directory directory =
            await getExternalStorageDirectory() ?? Directory('/');
        filePath =
            '${directory.path}/business_data_${DateTime.now().microsecondsSinceEpoch}.csv';
      }

      // Create a file and write the CSV data
      File file = File(filePath);
      await file.writeAsString(csvData);

      // Use Flutter File Dialog to show the save dialog
      final params = SaveFileDialogParams(
        sourceFilePath: filePath,
        mimeTypesFilter: ['text/csv'],
        fileName: 'people_data.csv',
      );
      final fileUri = await FlutterFileDialog.saveFile(params: params);

      // Optionally: Show a success message or do something with the fileUri
      print("CSV file saved at: $fileUri");
    } else {
      print('Permission denied');
    }
  }
}
