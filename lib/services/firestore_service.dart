import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Profiles ---
  Future<void> upsertUserProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    final docRef = _db.collection('users').doc(uid);
    // Use set with merge true to update without destroying existing data like 'email'
    await docRef.set({
      'name': name,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // --- Vehicles ---
  /// Watch vehicles query with optional filter matching UI state
  Stream<List<Vehicle>> watchVehicles({String? city, String? type}) {
    Query query = _db
        .collection('vehicles')
        .orderBy('createdAt', descending: true);

    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();
    });
  }

  // --- Bookings ---
  Future<bool> createBooking({
    required String renterUid,
    required String vehicleId,
    required String ownerUid,
    required DateTime start,
    required DateTime end,
    required double pricePerHour,
  }) async {
    try {
      final hours = end.difference(start).inHours;
      final total = hours > 0 ? (hours * pricePerHour) : 0.0;

      await _db.collection('bookings').add({
        'renterUid': renterUid,
        'ownerUid': ownerUid,
        'vehicleId': vehicleId,
        'startTime': Timestamp.fromDate(start),
        'endTime': Timestamp.fromDate(end),
        'totalAmount': total,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error creating booking: $e");
      return false;
    }
  }

  // --- Register Vehicle ---
  Future<bool> registerVehicle(Vehicle vehicle) async {
    try {
      await _db.collection('vehicles').doc(vehicle.id).set(vehicle.toMap());
      return true;
    } catch (e) {
      print("Error registering vehicle: $e");
      return false;
    }
  }

  // --- Favorites (Subcollection on User Profile) ---
  Future<void> addFavorite(String uid, String vehicleId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(vehicleId)
        .set({'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeFavorite(String uid, String vehicleId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(vehicleId)
        .delete();
  }

  // --- Seed Data Mock ---
  /// Called manually or via a debug button to populate empty firestore buckets
  Future<void> seedMockVehiclesIfEmpty() async {
    final countSnap = await _db.collection('vehicles').limit(1).get();
    if (countSnap.docs.isNotEmpty) return; // DB already has data

    final List<Map<String, dynamic>> dummies = [
      {
        'ownerUid': 'mockOwner123',
        'type': 'Cars',
        'brand': 'Hyundai',
        'model': 'i20',
        'year': 2022,
        'rating': 4.8,
        'pricePerHour': 150.0,
        'city': 'Current Location',
        'thumbnailUrl':
            'https://via.placeholder.com/400x250.png?text=Hyundai+i20',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'ownerUid': 'mockOwner456',
        'type': 'Cars',
        'brand': 'Honda',
        'model': 'City',
        'year': 2023,
        'rating': 4.9,
        'pricePerHour': 200.0,
        'city': 'Mumbai',
        'thumbnailUrl':
            'https://via.placeholder.com/400x250.png?text=Honda+City',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'ownerUid': 'mockOwner789',
        'type': 'Two-Wheelers',
        'brand': 'Royal Enfield',
        'model': 'Classic 350',
        'year': 2021,
        'rating': 4.7,
        'pricePerHour': 80.0,
        'city': 'Current Location',
        'thumbnailUrl':
            'https://via.placeholder.com/400x250.png?text=RE+Classic+350',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    print("Seeding dummy vehicles into Firestore...");
    for (var vehicleData in dummies) {
      await _db.collection('vehicles').add(vehicleData);
    }
  }
}
