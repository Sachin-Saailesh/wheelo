rules_version = '2';

service cloud.firestore {
match /databases/{database}/documents {

    // Helper function to check if the user is logged in
    function isAuthenticated() {
      return request.auth != null;
    }

    // ----------------------------------------------------------------------
    // Users Collection
    // ----------------------------------------------------------------------
    match /users/{userId} {
      // Anyone can read a user profile (needed for owner view, etc.)
      allow read: if true;
      // Users can only create/update their own profile
      allow write: if isAuthenticated() && request.auth.uid == userId;

      // User's private Favorites subcollection
      match /favorites/{vehicleId} {
        // Only the user can read/write their favorites
        allow read, write: if isAuthenticated() && request.auth.uid == userId;
      }
    }

    // ----------------------------------------------------------------------
    // Vehicles Collection
    // ----------------------------------------------------------------------
    match /vehicles/{vehicleId} {
      // Anyone can read public vehicle listings
      allow read: if true;
      // Authenticated users can create vehicles
      allow create: if isAuthenticated() && request.resource.data.ownerUid == request.auth.uid;
      // Only the vehicle owner can update or delete their listing
      allow update, delete: if isAuthenticated() && resource.data.ownerUid == request.auth.uid;
    }

    // ----------------------------------------------------------------------
    // Bookings Collection
    // ----------------------------------------------------------------------
    match /bookings/{bookingId} {
      // Users can read bookings if they are either the renter OR the vehicle owner
      allow read: if isAuthenticated() &&
        (resource.data.renterUid == request.auth.uid ||
         resource.data.ownerUid == request.auth.uid);

      // Any authenticated user can create a booking
      allow create: if isAuthenticated() && request.resource.data.renterUid == request.auth.uid;

      // Updates allowed if they are the renter or the owner
      // (e.g., owner approving/rejecting, renter cancelling)
      allow update: if isAuthenticated() &&
        (resource.data.renterUid == request.auth.uid ||
         resource.data.ownerUid == request.auth.uid);

      // Optional: Prevent hard deletes. Only allow status updates
      allow delete: if false;
    }

}
}
