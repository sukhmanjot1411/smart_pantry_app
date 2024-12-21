import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String name;
  final int quantity;
  final DateTime manufacturingDate;
  final DateTime expiryDate;
  String? id;

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.manufacturingDate,
    required this.expiryDate,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'manufacturingDate': Timestamp.fromDate(manufacturingDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
    };
  }

  static InventoryItem fromMap(Map<String, dynamic> map, String documentId) {
    return InventoryItem(
      id: documentId,
      name: map['name'],
      quantity: map['quantity'],
      manufacturingDate: (map['manufacturingDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
    );
  }
}