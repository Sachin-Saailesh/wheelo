import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String ownerUid;
  final String type; // 'Car', 'Two-Wheeler'
  final String brand;
  final String model;
  final int year;
  final double rating;
  final double pricePerHour;
  final String city;
  final String thumbnailUrl;
  final DateTime createdAt;
  bool isFavorite; // Local state for UI purposes

  Vehicle({
    required this.id,
    required this.ownerUid,
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.rating,
    required this.pricePerHour,
    required this.city,
    required this.thumbnailUrl,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      ownerUid: data['ownerUid'] ?? '',
      type: data['type'] ?? 'Car',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year']?.toInt() ?? 2020,
      rating: (data['rating'] ?? 0.0).toDouble(),
      pricePerHour: (data['pricePerHour'] ?? 0.0).toDouble(),
      city: data['city'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'type': type,
      'brand': brand,
      'model': model,
      'year': year,
      'rating': rating,
      'pricePerHour': pricePerHour,
      'city': city,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
