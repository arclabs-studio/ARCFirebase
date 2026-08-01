# Security Best Practices

Essential security guidelines for Firebase in production apps.

## Overview

Firebase is secure by default, but requires proper configuration. This guide covers critical security practices for production deployments.

## Firestore Security Rules

### Never Use Open Rules in Production

**INSECURE** (Development only):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // Anyone can read/write!
    }
  }
}
```

### User-Based Access Control

**SECURE** (Production):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                        && request.auth.uid == userId;
    }

    // Public read, authenticated write
    match /restaurants/{restaurantId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // Only owners can modify their favorites
    match /favorites/{favoriteId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
                    && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null
                           && resource.data.userId == request.auth.uid;
    }
  }
}
```

### Validate Data

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /restaurants/{restaurantId} {
      allow create: if request.auth != null
                    && request.resource.data.name is string
                    && request.resource.data.name.size() > 0
                    && request.resource.data.name.size() <= 100;
    }
  }
}
```

## Firebase Storage Security Rules

### User-Specific Folders

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only upload to their own folder
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null
                        && request.auth.uid == userId;
    }

    // Public read, authenticated write for restaurant photos
    match /restaurants/{restaurantId}/photos/{photoId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### File Size Limits

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/profile.jpg {
      allow write: if request.auth != null
                   && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024;  // 5 MB max
    }
  }
}
```

## Authentication Security

### Email Verification

```swift
import ARCFirebaseAuth

// After sign up, send verification email
let user = try await AuthManager.shared.signUp(
    email: "user@example.com",
    password: "password"
)

// In production, require email verification
guard user.isEmailVerified else {
    throw AppError.emailNotVerified
}
```

### Strong Password Requirements

Configure in Firebase Console:
- Minimum 8 characters
- Require uppercase and lowercase
- Require numbers
- Require special characters

### Rate Limiting

Firebase automatically rate-limits authentication attempts. Additionally:

```swift
// Implement exponential backoff for failed attempts
var retryDelay = 1.0

func signInWithRetry(email: String, password: String) async throws {
    do {
        return try await AuthManager.shared.signIn(email: email, password: password)
    } catch {
        try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
        retryDelay *= 2  // Exponential backoff
        throw error
    }
}
```

## API Key Protection

### Don't Commit Secrets

**Always** add to `.gitignore`:

```gitignore
# Firebase
GoogleService-Info.plist

# Environment variables
.env
.env.local
.env.production

# Secrets
secrets/
```

### iOS API Key Restrictions

In Firebase Console:
1. Go to APIs & Services → Credentials
2. Select your iOS API key
3. Add Application restrictions:
   - iOS apps
   - Bundle ID: `com.arclabs.favres`

### Use Environment-Specific Configs

```
FavRes/
├── Debug/
│   └── GoogleService-Info.plist  (Development project)
└── Release/
    └── GoogleService-Info.plist  (Production project)
```

## Data Privacy

### Never Log PII

```swift
// BAD
logger.info("User signed in: \(user.email)")  // PII in logs!

// GOOD
logger.info("User signed in: \(user.id)")  // Just the ID
```

### Anonymize Analytics

```swift
// Don't use email as user ID
AnalyticsManager.shared.setUserID(user.email)  // BAD!

// Use anonymous ID instead
AnalyticsManager.shared.setUserID(user.id)  // GOOD
```

### GDPR Compliance

```swift
// Implement data deletion
func deleteUserData(userId: String) async throws {
    // Delete Firestore data
    let userRepo = try FirestoreRepository<User>(collectionPath: "users")
    try await userRepo.delete(id: userId)

    // Delete Storage files
    try await StorageManager.shared.delete(path: "users/\(userId)")

    // Delete Auth account
    try await Auth.auth().currentUser?.delete()
}
```

## Network Security

### Enable App Transport Security

In `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

### Use HTTPS Only

Firebase automatically uses HTTPS. Never downgrade to HTTP.

## Monitoring and Alerts

### Enable Firebase Security Monitoring

1. Firebase Console → Security
2. Enable Security Rules monitoring
3. Set up alerts for:
   - Rule violations
   - Unusual access patterns
   - Failed authentication attempts

### Monitor with Crashlytics

```swift
// Log security events
if securityViolation {
    CrashlyticsManager.shared.log("Security violation: \(type)")
    CrashlyticsManager.shared.setCustomValue(userId, forKey: "violator_id")
}
```

## Checklist for Production

Before deploying to production:

- [ ] Firestore security rules enforce authentication
- [ ] Storage security rules enforce user-specific access
- [ ] Email verification required for sensitive operations
- [ ] API keys restricted to app bundle ID
- [ ] `GoogleService-Info.plist` in `.gitignore`
- [ ] No PII in logs or analytics
- [ ] GDPR data deletion implemented
- [ ] App Transport Security enabled
- [ ] Security monitoring alerts configured
- [ ] Password requirements enforced
- [ ] Rate limiting implemented for auth

## Resources

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Firebase Security Checklist](https://firebase.google.com/support/guides/security-checklist)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
