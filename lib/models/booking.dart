import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String renterUid;
  final String ownerUid;
  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalAmount;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.renterUid,
    required this.ownerUid,
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      renterUid: data['renterUid'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'renterUid': renterUid,
      'ownerUid': ownerUid,
      'vehicleId': vehicleId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
