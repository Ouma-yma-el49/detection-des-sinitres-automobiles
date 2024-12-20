import 'dart:io';

class Sinistre {

  final String policyNumber;
  final String description;
  final String damages;
  final String witnesses;
  final DateTime date;
  final DateTime time;
  final String carModel;
  final String carPlate;
  final File? image;
  final String label; // Image du sinistre

  Sinistre({

    required this.policyNumber,
    required this.description,
    required this.damages,
    required this.witnesses,
    required this.date,
    required this.time,
    required this.carModel,
    required this.carPlate,
    this.image,
    required this.label,
  });
}
