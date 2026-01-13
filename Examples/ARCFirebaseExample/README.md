# ARCFirebase Example App

A complete SwiftUI example demonstrating all ARCFirebase modules in action.

## Features Demonstrated

- **Authentication** (`ARCFirebaseAuth`)
  - Email/password sign up and sign in
  - User session management
  - Sign out functionality

- **Firestore** (`ARCFirebasePersistence`)
  - CRUD operations with generic repository
  - Real-time data synchronization
  - Type-safe models with `FirestoreDocument`

- **Analytics** (`ARCFirebaseAnalytics`)
  - Event tracking throughout the app
  - User property setting
  - Screen view logging

- **Crashlytics** (`ARCFirebaseCrashlytics`)
  - Error reporting
  - User context tracking
  - Custom logging

## Setup Instructions

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or use existing one)
3. Add an iOS app with bundle ID: `com.arclabs.arcfirebase.example`

### 2. Download Configuration File

1. In Firebase Console, go to Project Settings
2. Download `GoogleService-Info.plist`
3. **DO NOT** commit this file to git (it's in `.gitignore`)

### 3. Configure Firebase Services

Enable the following services in Firebase Console:

#### Authentication
- Go to Authentication → Sign-in method
- Enable **Email/Password** provider

#### Firestore Database
- Go to Firestore Database → Create database
- Start in **test mode** (for development)
- Use default location

#### Security Rules (Development)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      // ⚠️ WARNING: Open rules for development only!
      // Change these before production
      allow read, write: if true;
    }
  }
}
```

#### Analytics
- Automatically enabled with Firebase setup

#### Crashlytics
- Go to Crashlytics → Get started
- Follow SDK setup instructions (ARCFirebase already includes it)

### 4. Add to Your Xcode Project

Option A: **Copy Example Files**
```bash
# Copy the example directory into your project
cp -r Examples/ARCFirebaseExample YourProject/
```

Option B: **Create New Xcode Project**
1. Create new SwiftUI iOS project
2. Set bundle ID to `com.arclabs.arcfirebase.example`
3. Add ARCFirebase as package dependency
4. Copy source files from `Examples/ARCFirebaseExample/Sources`
5. Add `GoogleService-Info.plist` to project

### 5. Add ARCFirebase Dependency

In your Xcode project:
1. File → Add Package Dependencies
2. Enter ARCFirebase repository URL
3. Select the following products:
   - ARCFirebaseCore
   - ARCFirebaseAuth
   - ARCFirebaseAnalytics
   - ARCFirebaseCrashlytics
   - ARCFirebasePersistence

Or in `Package.swift`:
```swift
dependencies: [
    .package(path: "../../") // Path to ARCFirebase
]
```

### 6. Run the App

1. Build and run the app
2. Check console for "✅ Firebase configured successfully"
3. Sign up with a test email (e.g., `test@example.com`)
4. Start creating items!

## Code Structure

```
Sources/
├── ARCFirebaseExampleApp.swift   # App entry point + Firebase setup
├── Models/
│   └── Item.swift                # Firestore model example
├── ViewModels/
│   ├── AuthViewModel.swift       # Authentication logic
│   └── ItemsViewModel.swift      # Firestore CRUD logic
└── Views/
    ├── ContentView.swift          # Main navigation
    ├── Auth/
    │   ├── SignInView.swift      # Sign in screen
    │   └── SignUpView.swift      # Sign up screen
    └── Firestore/
        └── ItemsListView.swift   # Items list + detail
```

## Key Implementation Patterns

### Firebase Configuration
```swift
@main
struct ARCFirebaseExampleApp: App {
    init() {
        // 1. Configure Firebase Core
        FirebaseManager.configure()

        // 2. Configure services
        try? AuthManager.shared.configure()
        try? AnalyticsManager.shared.configure()
        try? CrashlyticsManager.shared.configure()
    }
}
```

### Authentication Flow
```swift
@Observable
final class AuthViewModel {
    func signIn() async {
        let user = try await AuthManager.shared.signIn(
            email: email,
            password: password
        )

        // Track event
        AnalyticsManager.shared.logEvent("user_signed_in")

        // Set user context
        AnalyticsManager.shared.setUserID(user.id)
        CrashlyticsManager.shared.setUserID(user.id)
    }
}
```

### Firestore Repository
```swift
// Define model
struct Item: FirestoreDocument {
    let id: String
    let title: String
    let createdAt: Date
    let updatedAt: Date
}

// Use repository
let repository = try FirestoreRepository<Item>(collectionPath: "items")

// CRUD operations
try await repository.save(item)
let items = try await repository.fetchAll()
try await repository.delete(id: itemId)
```

### Error Handling
```swift
do {
    try await repository.save(item)
} catch {
    // Report to Crashlytics
    CrashlyticsManager.shared.record(error: error)

    // Show to user
    errorMessage = error.localizedDescription
}
```

## Testing the App

### 1. Sign Up
- Tap "Don't have an account? Sign Up"
- Enter email and password (min 6 characters)
- Tap "Sign Up"
- You should be automatically signed in

### 2. Create Items
- Tap "+" in the Items tab
- Enter title and description
- Tap "Add Item"
- Item appears in the list

### 3. View Analytics
- Go to Firebase Console → Analytics
- Wait a few minutes for events to appear
- See `app_opened`, `user_signed_in`, `item_created` events

### 4. Test Crashlytics
- Force a test crash:
```swift
Button("Test Crash") {
    fatalError("Test crash")
}
```
- Reopen app
- Check Firebase Console → Crashlytics

## Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules (see below)
- [ ] Enable email verification
- [ ] Set up proper error handling
- [ ] Add loading states
- [ ] Implement offline support
- [ ] Add data validation
- [ ] Test on physical device
- [ ] Configure Firebase App Check

### Production Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own items
    match /items/{itemId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
                    && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null
                            && resource.data.userId == request.auth.uid;
    }
  }
}
```

## Troubleshooting

### "Firebase not configured" Error
- Ensure `GoogleService-Info.plist` is in your project
- Check it's added to your app target
- Verify `FirebaseManager.configure()` is called first

### Authentication Errors
- Check Email/Password is enabled in Firebase Console
- Verify password is at least 6 characters
- Check Firebase Console → Authentication for error logs

### Firestore Permission Denied
- Check security rules in Firebase Console
- For development, use open rules (see above)
- For production, implement proper rules

### No Analytics Events
- Analytics can take up to 24 hours to appear
- Use DebugView in Firebase Console for real-time events
- Enable Analytics debug mode in scheme settings

## Cost Estimate (Free Tier)

Firebase offers generous free tiers:

- **Authentication**: 50,000 MAU (Monthly Active Users)
- **Firestore**: 1 GB storage, 50,000 reads/day
- **Analytics**: Unlimited events
- **Crashlytics**: Unlimited crash reports

This example app will run **completely free** for personal use and small-scale testing.

## Next Steps

- Add image upload with `ARCFirebaseStorage`
- Implement real-time listeners
- Add push notifications
- Create admin panel
- Deploy to TestFlight

## License

This example is part of ARCFirebase and licensed under MIT License.

## Support

For issues or questions:
- Check ARCFirebase documentation
- Review Firebase Console logs
- Consult [Firebase documentation](https://firebase.google.com/docs)
