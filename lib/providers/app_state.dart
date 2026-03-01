import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/vehicle.dart';

class AppState extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Selected filters for vehicle streams
  String _selectedCity = '';
  String _selectedType = 'Cars'; // default matching UI

  String get selectedCity => _selectedCity;
  String get selectedType => _selectedType;

  // Stream getter to pipe directly to the UI
  Stream<List<Vehicle>> get vehicleStream =>
      _firestoreService.watchVehicles(city: _selectedCity, type: _selectedType);

  void updateFilters(String city, String type) {
    _selectedCity = city;
    _selectedType = type;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- Auth Wrappers ---

  Future<void> sendOtp({
    required String phone,
    required String name,
    required Function(String, int?) onCodeSent,
    required Function(FirebaseAuthException) onError,
    required Function(PhoneAuthCredential) onAutoVerified,
  }) async {
    setLoading(true);
    await _authService.sendOtp(
      phone: phone,
      name: name,
      onCodeSent: (verId, token) {
        setLoading(false);
        onCodeSent(verId, token);
      },
      onError: (e) {
        setLoading(false);
        onError(e);
      },
      onAutoVerified: (cred) {
        setLoading(false);
        onAutoVerified(cred);
      },
    );
  }

  Future<bool> verifyOtp(
    String verificationId,
    String smsCode,
    String name,
    String phone,
  ) async {
    setLoading(true);
    bool success = await _authService.verifyOtpAndLogin(
      verificationId,
      smsCode,
      name,
      phone,
    );
    setLoading(false);
    return success;
  }

  Future<bool> signInWithGoogle() async {
    setLoading(true);
    bool success = await _authService.signInWithGoogle();
    setLoading(false);
    return success;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  // --- Firestore Wrappers ---

  Future<bool> registerHostListing(Map<String, dynamic> data) async {
    setLoading(true);
    final user = _authService.currentUser;
    if (user == null) {
      setLoading(false);
      return false;
    }

    final vehicleDoc = FirebaseFirestore.instance.collection('vehicles').doc();

    final vehicle = Vehicle(
      id: vehicleDoc.id,
      ownerUid: user.uid,
      type: 'Cars', // Standardize to match filtering UI
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      rating: 0.0,
      pricePerHour: data['price'] ?? 0.0,
      city: data['city'] ?? 'Unknown',
      thumbnailUrl: 'https://via.placeholder.com/400x200?text=New+Listing',
      createdAt: DateTime.now(),
    );

    bool success = await _firestoreService.registerVehicle(vehicle);
    setLoading(false);
    return success;
  }

  Future<bool> createBooking(
    Vehicle vehicle,
    DateTime start,
    DateTime end,
    String paymentMethod,
  ) async {
    setLoading(true);
    final user = _authService.currentUser;
    if (user == null) {
      setLoading(false);
      return false; // Must be logged in to book
    }

    bool success = await _firestoreService.createBooking(
      renterUid: user.uid,
      ownerUid: vehicle.ownerUid,
      vehicleId: vehicle.id,
      start: start,
      end: end,
      pricePerHour: vehicle.pricePerHour,
    );

    setLoading(false);
    return success;
  }

  Future<void> seedMockVehiclesIfEmpty() async {
    setLoading(true);
    await _firestoreService.seedMockVehiclesIfEmpty();
    setLoading(false);
  }
}
