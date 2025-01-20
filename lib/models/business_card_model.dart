import 'dart:convert';

List<String> businessCardModelListToString(List<BusinessCardModel> data) =>
    List<String>.from(data.map((x) => json.encode(x.toJson())));

class BusinessCardModel {
  final String id;
  final String name;
  final String position;
  final String company;
  final String email;
  final String phone;
  final String website;
  final String address;
  final List<String> additionalPhones;
  final List<String> additionalEmails;
  final String note;
  final String specification;
  final String imageFilePath;
  final String dateTime;

  // New field to store selected fields
  final List<String> selectedFields;

  BusinessCardModel({
    this.id = "",
    required this.name,
    required this.position,
    required this.company,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.additionalPhones,
    required this.additionalEmails,
    required this.note,
    required this.specification,
    required this.imageFilePath,
    required this.dateTime,
    this.selectedFields = const [],
  });

  factory BusinessCardModel.fromText(
    String text,
  ) {
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
      RegExp(r'^[A-Z][A-Za-z\s\.-]{2,}$'), // Matches capitalized names
      RegExp(r'name[\s:]([A-Za-z\s\.-]+)',
          caseSensitive: false), // Matches "Name: John Doe"
      RegExp(r'([A-Z][a-z]+\s+[A-Z][a-z]+)'), // Matches "John Doe" format
    ];

    final emailPattern =
        RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
    final phonePattern =
        RegExp(r'[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}');
    final websitePattern = RegExp(
        r'(?:www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?',
        caseSensitive: false);
    final positionPattern = RegExp(
        r'(director|manager|engineer|developer|coordinator|supervisor|officer|specialist|analyst|consultant)',
        caseSensitive: false);

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
            name = nameMatch.groupCount >= 1
                ? (nameMatch.group(1) ?? line).trim()
                : nameMatch.group(0)?.trim() ?? '';
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
        emails.addAll(emailMatches
            .map((m) => m.group(0) ?? '')
            .where((email) => email.isNotEmpty));
        continue;
      }

      // Find phone numbers
      final phoneMatches = phonePattern.allMatches(line);
      if (phoneMatches.isNotEmpty) {
        phones.addAll(phoneMatches
            .map((m) => m.group(0) ?? '')
            .where((phone) => phone.isNotEmpty));
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
          !line.contains(
              RegExp(r'address|location|po box', caseSensitive: false)) &&
          !phonePattern.hasMatch(line) &&
          !emailPattern.hasMatch(line) &&
          !websitePattern.hasMatch(line)) {
        company = line.trim();
        continue;
      }

      // Process address
      if (line.contains(
              RegExp(r'address|location|po box', caseSensitive: false)) ||
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

    return BusinessCardModel(
      name: name,
      company: company,
      position: position,
      email: emails.isNotEmpty ? emails.first : '',
      phone: phones.isNotEmpty ? phones.first : '',
      address: address,
      website: website,
      additionalPhones: phones.length > 1 ? phones.sublist(1) : [],
      additionalEmails: emails.length > 1 ? emails.sublist(1) : [],
      note: "",
      specification: "",
      imageFilePath: '',
      dateTime: '',
    );
  }

  factory BusinessCardModel.fromJson(Map<String, dynamic> json) =>
      BusinessCardModel(
        id: json["id"] ?? '',
        name: json["name"] ?? " ",
        position: json["position"] ?? " ",
        company: json["company"] ?? " ",
        email: json["email"] ?? " ",
        phone: json["phone"] ?? " ",
        website: json["website"] ?? " ",
        address: json["address"] ?? " ",
        additionalPhones: json["additional_phones"] != null
            ? List<String>.from(json["additional_phones"].map((x) => x))
            : [],
        additionalEmails: json["additional_emails"] != null
            ? List<String>.from(json["additional_emails"].map((x) => x))
            : [],
        note: json["note"] ?? " ",
        specification: json["specification"] ?? " ",
        imageFilePath: json["image_file_path"] ?? " ",
        dateTime: json["date_time"] ?? " ",
        selectedFields: json["selected_fields"] != null
            ? List<String>.from(json["selected_fields"].map((x) => x))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "position": position,
        "company": company,
        "email": email,
        "phone": phone,
        "website": website,
        "address": address,
        "additional_phones": List<dynamic>.from(additionalPhones.map((x) => x)),
        "additional_emails": List<dynamic>.from(additionalEmails.map((x) => x)),
        "note": note,
        "specification": specification,
        "image_file_path": imageFilePath,
        "date_time": dateTime,
        "id": id,
        "selected_fields": List<dynamic>.from(selectedFields.map((x) => x)),
      };
}
