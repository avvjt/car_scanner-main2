// lib/models/business_card.dart
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class BusinessCard extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String company;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String phone;
  @HiveField(4)
  final String address;
  @HiveField(5)
  final String website;
  @HiveField(6)
  final String position;
  @HiveField(7)
  final List<String> additionalPhones;
  @HiveField(8)
  final List<String> additionalEmails;
  @HiveField(9)
  final String imagePath;
  @HiveField(10)
  final DateTime dateAdded;

  BusinessCard({
    this.name = '',
    this.company = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.website = '',
    this.position = '',
    this.additionalPhones = const [],
    this.additionalEmails = const [],
    this.imagePath = '',
    DateTime? dateAdded,
  }) : this.dateAdded = dateAdded ?? DateTime.now();

  factory BusinessCard.fromText(String text) {
    // Split text into lines for better processing
    final lines = text.split('\n').map((line) => line.trim()).toList();

    // Initialize variables to store extracted data
    String name = '';
    String company = '';
    String position = '';
    String address = '';
    List<String> phones = [];
    List<String> emails = [];
    String website = '';

    // Fixed and improved regular expressions
    final namePatterns = [
      RegExp(r'^[A-Z][A-Za-z\s\.-]{2,}$'),  // Matches capitalized names
      RegExp(r'name[\s:]([A-Za-z\s\.-]+)', caseSensitive: false),  // Matches "Name: John Doe"
      RegExp(r'([A-Z][a-z]+\s+[A-Z][a-z]+)'),  // Matches "John Doe" format
    ];

    final emailPattern = RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
    final phonePattern = RegExp(r'[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}');
    final websitePattern = RegExp(r'(?:www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?', caseSensitive: false);
    final positionPattern = RegExp(r'(director|manager|engineer|developer|coordinator|supervisor|officer|specialist|analyst|consultant)', caseSensitive: false);

    bool isProcessingAddress = false;
    List<String> addressLines = [];

    // Process each line
    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Try to find name
      if (name.isEmpty) {
        for (var pattern in namePatterns) {
          final nameMatch = pattern.firstMatch(line);
          if (nameMatch != null) {
            // Get the name from the first capturing group if it exists, otherwise use the whole match
            name = nameMatch.groupCount >= 1 ?
            (nameMatch.group(1) ?? line).trim() :
            nameMatch.group(0)?.trim() ?? '';
            if (name.isNotEmpty) break;
          }
        }
        if (name.isNotEmpty) continue;
      }

      // Find position/title
      if (position.isEmpty && positionPattern.hasMatch(line)) {
        position = line.trim();
        continue;
      }

      // Find email addresses
      final emailMatches = emailPattern.allMatches(line);
      if (emailMatches.isNotEmpty) {
        emails.addAll(
            emailMatches
                .map((m) => m.group(0) ?? '')
                .where((email) => email.isNotEmpty)
        );
        continue;
      }

      // Find phone numbers
      final phoneMatches = phonePattern.allMatches(line);
      if (phoneMatches.isNotEmpty) {
        phones.addAll(
            phoneMatches
                .map((m) => m.group(0) ?? '')
                .where((phone) => phone.isNotEmpty)
        );
        continue;
      }

      // Find website
      if (website.isEmpty) {
        final websiteMatch = websitePattern.firstMatch(line);
        if (websiteMatch != null) {
          website = websiteMatch.group(0) ?? '';
          continue;
        }
      }

      // Process company name
      if (company.isEmpty &&
          !line.contains(RegExp(r'address|location|po box', caseSensitive: false)) &&
          !phonePattern.hasMatch(line) &&
          !emailPattern.hasMatch(line) &&
          !websitePattern.hasMatch(line)) {
        company = line.trim();
        continue;
      }

      // Process address
      if (line.contains(RegExp(r'address|location|po box', caseSensitive: false)) ||
          isProcessingAddress) {
        isProcessingAddress = true;
        // Don't add the "Address:" label to the address
        if (!line.contains(RegExp(r'address|location', caseSensitive: false))) {
          addressLines.add(line);
        }
      }
    }

    // Clean up address
    if (addressLines.isNotEmpty) {
      address = addressLines.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    return BusinessCard(
      name: name,
      company: company,
      position: position,
      email: emails.isNotEmpty ? emails.first : '',
      phone: phones.isNotEmpty ? phones.first : '',
      address: address,
      website: website,
      additionalPhones: phones.length > 1 ? phones.sublist(1) : [],
      additionalEmails: emails.length > 1 ? emails.sublist(1) : [],
    );
  }

  @override
  String toString() {
    return '''
    Name: $name
    Position: $position
    Company: $company
    Email: $email
    Phone: $phone
    Website: $website
    Address: $address
    Additional Phones: ${additionalPhones.join(', ')}
    Additional Emails: ${additionalEmails.join(', ')}
    ''';
  }
}
class BusinessCardAdapter extends TypeAdapter<BusinessCard> {
  @override
  final int typeId = 0;

  @override
  BusinessCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessCard(
      name: fields[0] as String,
      company: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      address: fields[4] as String,
      website: fields[5] as String,
      position: fields[6] as String,
      additionalPhones: (fields[7] as List).cast<String>(),
      additionalEmails: (fields[8] as List).cast<String>(),
      imagePath: fields[9] as String,
      dateAdded: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessCard obj) {
    writer.writeByte(11);
    writer.writeByte(0);
    writer.write(obj.name);
    writer.writeByte(1);
    writer.write(obj.company);
    writer.writeByte(2);
    writer.write(obj.email);
    writer.writeByte(3);
    writer.write(obj.phone);
    writer.writeByte(4);
    writer.write(obj.address);
    writer.writeByte(5);
    writer.write(obj.website);
    writer.writeByte(6);
    writer.write(obj.position);
    writer.writeByte(7);
    writer.write(obj.additionalPhones);
    writer.writeByte(8);
    writer.write(obj.additionalEmails);
    writer.writeByte(9);
    writer.write(obj.imagePath);
    writer.writeByte(10);
    writer.write(obj.dateAdded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BusinessCardAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}