# ARCFirebase Example App

A complete SwiftUI iOS app demonstrating all ARCFirebase modules in action. This demo app follows **ARC Labs Studio standards** and serves as both a learning resource and a reference implementation.

> **Project Type**: Xcode Project (generated with XcodeGen)

## Features Demonstrated

### Authentication (`ARCFirebaseAuth`)
- Email/password sign up and sign in
- User session management
- Sign out functionality
- User context for analytics and crashlytics

### Firestore (`ARCFirebasePersistence`)
- CRUD operations with generic `FirestoreRepository<T>`
- Type-safe models with `FirestoreDocument` protocol
- Automatic timestamp management
- User-owned data with `userId` field

### Cloud Storage (`ARCFirebaseStorage`)
- File upload with content type
- Download URL retrieval
- In-memory file download
- File deletion

### Analytics (`ARCFirebaseAnalytics`)
- Event tracking throughout the app
- User property setting
- Screen view logging
- User ID attribution

### Crashlytics (`ARCFirebaseCrashlytics`)
- Error recording
- Non-fatal error logging
- User context tracking
- Custom logging

### AI Chat (`ARCFirebaseAI`)
- Content generation with Gemini 2.0 Flash via Firebase AI
- Real-time streaming (word-by-word response display)
- Multi-turn conversations with context history
- Configuration presets (Default, Creative, Factual)

---

## Architecture

This demo follows **ARC Labs Studio architecture patterns**:

```
ARCFirebaseExample/
├── ARCFirebaseExample.xcodeproj  # Xcode project
├── project.yml                   # XcodeGen configuration
├── Sources/
│   ├── ARCFirebaseExampleApp.swift   # App entry + Firebase config
│   ├── Models/
│   │   └── Item.swift                # FirestoreDocument example
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift       # Authentication state
│   │   └── ItemsViewModel.swift      # Firestore CRUD
│   ├── Views/
│   │   ├── ContentView.swift         # Root view + tabs
│   │   ├── Auth/
│   │   │   ├── SignInView.swift
│   │   │   └── SignUpView.swift
│   │   ├── AI/
│   │   │   └── AIChatView.swift      # Gemini chat demo
│   │   ├── Firestore/
│   │   │   └── ItemsListView.swift
│   │   └── Storage/
│   │       └── StorageDemoView.swift
│   └── Mocks/
│       ├── MockAIProvider.swift
│       ├── MockAuthProvider.swift
│       ├── MockAnalyticsProvider.swift
│       ├── MockStorageProvider.swift
│       ├── MockCrashlyticsProvider.swift
│       └── PreviewHelpers.swift
└── Resources/
    └── GoogleService-Info-Template.plist
```

### Key Patterns

1. **Protocol-based Providers**: All Firebase services are accessed through protocols
2. **Environment Injection**: Providers distributed via SwiftUI Environment
3. **@Observable ViewModels**: State management with Swift's Observation framework
4. **Mock Providers**: Enable SwiftUI previews without Firebase configuration

---

## Setup Instructions

### 1. Generate Xcode Project (if needed)

If you modified `project.yml`, regenerate the project:

```bash
cd Examples/ARCFirebaseExample
xcodegen generate
```

### 2. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or use existing one)
3. Add an iOS app with bundle ID: `com.arclabs.arcfirebase.example`

### 3. Download Configuration File

1. In Firebase Console, go to Project Settings
2. Download `GoogleService-Info.plist`
3. Add it to your Xcode project (NOT committed to git)

### 4. Enable Firebase Services

#### Authentication
- Go to Authentication → Sign-in method
- Enable **Email/Password** provider

#### Firestore Database
- Go to Firestore Database → Create database
- Start in **test mode** (for development)

#### Cloud Storage
- Go to Storage → Get started
- Use default bucket

#### Crashlytics
- Go to Crashlytics → Get started
- Follow setup instructions

#### Firebase AI (Gemini)
- Go to [Firebase AI Logic](https://console.firebase.google.com) → Build with Gemini
- Enable the Gemini API for your project

### 5. Development Security Rules

**Firestore (Development Only):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Storage (Development Only):**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

### 6. Run the App

```bash
# Open in Xcode
cd Examples/ARCFirebaseExample
open ARCFirebaseExample.xcodeproj

# Or build from command line
xcodebuild -project ARCFirebaseExample.xcodeproj \
           -scheme ARCFirebaseExample \
           -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
           build
```

---

## Code Examples

### Firebase Configuration

```swift
@main
struct ARCFirebaseExampleApp: App {
    init() {
        // 1. Configure Firebase Core
        FirebaseManager.configure()

        // 2. Initialize providers
        let auth = try FirebaseAuthProvider.create()
        let analytics = try FirebaseAnalyticsProvider.create()
        let storage = try FirebaseStorageProvider.create()
        let crashlytics = try FirebaseCrashlyticsProvider.create()
    }
}
```

### Authentication Flow

```swift
@Observable
final class AuthViewModel {
    func signIn() async {
        let user = try await auth.signIn(email: email, password: password)

        // Track event
        analytics.logEvent("user_signed_in", parameters: ["method": "email"])

        // Set user context
        analytics.setUserID(user.id)
        crashlytics.setUserID(user.id)
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
let items = try await repository.fetchAll()
try await repository.save(item)
try await repository.delete(id: itemId)
```

### Storage Upload

```swift
let storage: StorageProviding = try FirebaseStorageProvider.create()

let downloadURL = try await storage.upload(
    data: imageData,
    path: "images/\(UUID().uuidString).jpg",
    contentType: "image/jpeg"
)
```

### AI Content Generation

```swift
let ai: AIProviding = try FirebaseAIProvider.create()

// One-shot generation
let response = try await ai.generateContent(
    prompt: "Suggest a restaurant in Tokyo",
    configuration: .creative
)
print(response.content)

// Streaming
for try await chunk in ai.streamContent(prompt: "Tell me about sushi") {
    print(chunk, terminator: "")
}
```

---

## SwiftUI Previews

All views include functional previews using mock providers:

```swift
#Preview("Sign In - Empty") {
    let viewModel = AuthViewModel(
        auth: MockAuthProvider.unauthenticated,
        analytics: MockAnalyticsProvider.preview
    )

    return SignInView()
        .environment(viewModel)
        .previewEnvironment()
}

#Preview("Sign In - Dark Mode") {
    SignInView()
        .previewEnvironment()
        .preferredColorScheme(.dark)
}
```

---

## XcodeGen

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project generation.

### Regenerating the Project

```bash
# Install XcodeGen (if not installed)
brew install xcodegen

# Generate project
cd Examples/ARCFirebaseExample
xcodegen generate
```

### Modifying the Project

Edit `project.yml` to:
- Add new source files
- Add new dependencies
- Change build settings
- Add new targets

Then regenerate with `xcodegen generate`.

---

## Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules for user isolation
- [ ] Update Storage security rules
- [ ] Enable email verification
- [ ] Configure Firebase App Check
- [ ] Remove debug buttons
- [ ] Test on physical device
- [ ] Add proper error recovery
- [ ] Implement offline support

### Production Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
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

---

## Troubleshooting

### "Firebase not configured" Error
- Ensure `GoogleService-Info.plist` is in your project
- Verify it's added to your app target
- Check `FirebaseManager.configure()` is called first

### Previews Not Working
- Make sure mock providers are properly initialized
- Use `.previewEnvironment()` modifier
- Check for compiler errors in mock files

### Authentication Errors
- Check Email/Password is enabled in Firebase Console
- Verify password is at least 6 characters
- Check Firebase Console → Authentication for logs

### Project Generation Issues
- Run `xcodegen generate` to regenerate
- Check `project.yml` for syntax errors
- Ensure ARCFirebase package path is correct

---

## License

This example is part of ARCFirebase and follows ARC Labs Studio standards.
