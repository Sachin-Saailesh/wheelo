# Changelog

All notable changes to the Wheelo project will be documented in this file.

## [Unreleased]

### Added

- Integrated Firebase Authentication for user and host sign-up/login.
- Integrated Cloud Firestore for database management.
- Implemented core data models: `user_profile.dart`, `vehicle.dart`, and `booking.dart`.
- Developed UI screens including:
  - `home_screen.dart`
  - `login_screen.dart`
  - `otp_screen.dart`
  - `host_registration_screen.dart`
  - `vehicle_details_screen.dart`
  - `rent_vehicle_screen.dart`
  - `booking_screen.dart`
  - `location_permission_screen.dart`
  - `splash_screen.dart`
- Added Firebase security rules documentation in `docs/firebase_rules.md`.
- Implemented application services: `auth_service.dart` and `firestore_service.dart`.
- Created custom UI widgets such as `pill_button.dart`, `vehicle_card.dart`, and `search_details_overlay.dart`.

### Changed

- Resolved type conversion errors within the Firebase integration.
- Updated vehicle image URLs to display correctly.
- Refactored UI syntax and fixed compilation errors post-Firebase integration.

### Fixed

- Stabilized user profile data retrieval and host registration flow.
