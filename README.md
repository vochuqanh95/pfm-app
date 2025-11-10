# Personal Finance Management App - Authentication Module

A complete Flutter authentication module with Firebase integration, featuring Material 3 design and comprehensive user management.

## Features

- **Email/Password Authentication** with Firebase
- **User Profile Management** stored in Firestore
- **Automatic Wallet Creation** on registration
- **Session Persistence** with auth state management
- **Password Reset** functionality
- **Material 3 Design** with custom blue theme (#1E88E5)
- **Riverpod State Management**
- **GoRouter Navigation** with auth guards
- **Secure Token Storage** with flutter_secure_storage

## Tech Stack

- **Flutter 3.x** / **Dart 3.x**
- **Firebase Authentication** - Email/Password
- **Cloud Firestore** - User profiles and wallets
- **Riverpod** - State management
- **GoRouter** - Navigation and routing
- **Google Fonts** - Poppins typography
- **flutter_secure_storage** - Secure token storage
- **flutter_lints** - Code quality

## Project Structure

```
lib/
├─ main.dart                          # App entry point
├─ firebase_options.dart              # Firebase configuration
├─ core/
│   ├─ theme.dart                     # Material 3 theme with #1E88E5
│   ├─ router.dart                    # GoRouter with auth guards
│   └─ validators.dart                # Form validation utilities
├─ features/
    ├─ auth/
    │   ├─ data/
    │   │   ├─ auth_repository.dart   # Firebase Auth wrapper
    │   │   └─ user_repository.dart   # Firestore user operations
    │   ├─ domain/
    │   │   └─ app_user.dart          # User model
    │   ├─ presentation/
    │   │   ├─ login_page.dart        # Login screen
    │   │   ├─ register_page.dart     # Registration screen
    │   │   ├─ forgot_password_page.dart
    │   │   └─ widgets/
    │   │        ├─ auth_text_field.dart
    │   │        └─ primary_button.dart
    │   └─ provider/
    │       └─ auth_provider.dart     # Riverpod providers
    └─ home/
        └─ home_page.dart             # Protected home screen
```

## Prerequisites

Before you begin, ensure you have installed:

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (3.0.0 or higher)
- **VS Code** or **Android Studio**
- **Firebase CLI** (optional but recommended)
- **Node.js** (for Firebase CLI)

## Setup Instructions

### Step 1: Clone and Install Dependencies

```bash
# Navigate to project directory
cd pfm-app

# Get Flutter dependencies
flutter pub get
```

### Step 2: Configure Firebase

#### Option A: Automatic Configuration (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for your project
flutterfire configure
```

This will:
- Create or select a Firebase project
- Register your Flutter app
- Generate `lib/firebase_options.dart` with correct values

#### Option B: Manual Configuration

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing
3. Add apps (Web, Android, iOS)
4. Copy configuration values
5. Update `lib/firebase_options.dart` with your values

### Step 3: Enable Firebase Authentication

1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Authentication** → **Sign-in method**
4. Enable **Email/Password** provider
5. Click **Save**

### Step 4: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (for development)
4. Choose your preferred location
5. Click **Enable**

### Step 5: Set Firestore Security Rules (Optional)

For production, update your Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Wallets collection
    match /wallets/{walletId} {
      allow read, write: if request.auth != null &&
                         resource.data.user_id == request.auth.uid;
    }
  }
}
```

## Running the App

### Run on Emulator/Simulator

```bash
# Start your emulator first, then:
flutter run
```

### Run on Physical Device

```bash
# Connect device via USB and enable USB debugging
flutter devices  # Verify device is connected
flutter run
```

### Run on Web

```bash
flutter run -d chrome
```

### Run Specific Platform

```bash
flutter run -d android
flutter run -d ios
flutter run -d web
```

## Testing the App

### Test Flow 1: Registration

1. Launch app (redirects to Login page)
2. Click **"Create account"**
3. Fill in:
   - Name: John Doe
   - Email: john@example.com
   - Password: password123
   - Confirm Password: password123
4. Click **"Create Account"**
5. Verify:
   - Redirects to Home page
   - User document created in Firestore `users` collection
   - Default "Cash" wallet created in `wallets` collection
   - ID token printed in console

### Test Flow 2: Login

1. From Login page, enter credentials
2. Click **"Sign In"**
3. Verify:
   - Redirects to Home page
   - User profile displayed
   - ID token printed in console

### Test Flow 3: Forgot Password

1. From Login page, click **"Forgot password?"**
2. Enter email address
3. Click **"Send Reset Email"**
4. Check email for password reset link
5. Follow link to reset password

### Test Flow 4: Logout

1. From Home page, click logout icon or button
2. Confirm sign out
3. Verify:
   - Redirects to Login page
   - Session cleared
   - Cannot access Home page without login

### Test Flow 5: Session Persistence

1. Login to the app
2. Close the app completely
3. Reopen the app
4. Verify:
   - Automatically redirects to Home page
   - Session persisted
   - No need to login again

## Firestore Data Structure

### Users Collection (`users`)

```json
{
  "user_id": "uid",
  "name": "John Doe",
  "email": "john@example.com",
  "currency": "VND",
  "language": "vi",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### Wallets Collection (`wallets`)

```json
{
  "wallet_id": "auto-generated",
  "user_id": "uid",
  "group_id": null,
  "name": "Cash",
  "type": "cash",
  "currency": "VND",
  "opening_balance": 0,
  "balance": 0,
  "archived": false,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

## Common Issues and Solutions

### Issue: Firebase not configured

**Error:** `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution:** Run `flutterfire configure` to set up Firebase configuration.

### Issue: Build fails with dependency errors

**Solution:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Issue: Email/Password sign-in disabled

**Error:** `[auth/operation-not-allowed]`

**Solution:** Enable Email/Password provider in Firebase Console Authentication settings.

### Issue: Firestore permission denied

**Error:** `[PERMISSION_DENIED]`

**Solution:** Update Firestore security rules or start in test mode during development.

### Issue: ID Token not printing

**Solution:** Check console output. Token is printed with prefix `DEBUG - ID Token:` after successful login/registration.

## Development Tips

1. **Hot Reload**: Press `r` in terminal or use IDE hot reload
2. **Hot Restart**: Press `R` in terminal for full restart
3. **Debug Mode**: Run with `flutter run --debug`
4. **Release Mode**: Run with `flutter run --release`
5. **View Logs**: `flutter logs` in separate terminal

## Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules
- [ ] Remove test mode from Firestore
- [ ] Configure proper email templates in Firebase
- [ ] Set up email verification flow
- [ ] Add Google Sign-In (optional)
- [ ] Remove debug print statements for ID tokens
- [ ] Enable ProGuard/R8 for Android
- [ ] Test on multiple devices and screen sizes
- [ ] Add error tracking (Firebase Crashlytics, Sentry)
- [ ] Implement proper analytics

## Future Enhancements

- Google Sign-In integration
- Apple Sign-In for iOS
- Phone authentication
- Biometric authentication
- Multi-factor authentication
- Email verification flow
- Profile photo upload
- Account deletion
- Settings page

## Code Quality

The project uses `flutter_lints` for code quality:

```bash
# Run linter
flutter analyze

# Run tests (when added)
flutter test

# Format code
dart format lib/
```

## License

This project is part of a Personal Finance Management application.

## Support

For issues and questions:
1. Check Firebase Console for auth/database errors
2. Review Flutter logs with `flutter logs`
3. Verify all Firebase services are enabled
4. Check `lib/firebase_options.dart` has correct values

---

**Built with Flutter 3.x | Firebase | Material 3**
