# Firestore Patterns

Learn best practices for using Firestore with the Repository pattern.

## Overview

This guide covers how to use FirestoreRepository effectively in your apps.

## Basic Setup

```swift
import ARCFirebasePersistence

// Define your model
struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
    let rating: Double
}

// Create repository
let repository = try FirestoreRepository<Restaurant>(
    collectionPath: "restaurants"
)
```

## CRUD Operations

### Create

```swift
let restaurant = Restaurant(
    id: UUID().uuidString,
    name: "Pasta Paradise",
    category: "italian",
    rating: 4.5
)

try await repository.save(restaurant)
```

### Read

```swift
// Fetch single document
if let restaurant = try await repository.fetch(id: "abc123") {
    print(restaurant.name)
}

// Fetch all documents
let allRestaurants = try await repository.fetchAll()
```

### Update

```swift
var restaurant = try await repository.fetch(id: "abc123")!
restaurant.rating = 4.8
try await repository.update(restaurant)
```

### Delete

```swift
try await repository.delete(id: "abc123")
```

## Advanced Queries

### Filter by Field

```swift
let italianRestaurants = try await repository.query(
    where: "category",
    isEqualTo: "italian"
)
```

### Order and Limit

```swift
let topRestaurants = try await repository.query(
    orderBy: "rating",
    descending: true,
    limit: 10
)
```

## Firestore Document Protocol

For models with timestamps:

```swift
struct Restaurant: FirestoreDocument {
    let id: String
    let name: String
    let category: String
    let createdAt: Date
    let updatedAt: Date
}

// Create with timestamps
let restaurant = Restaurant.withTimestamps { now in
    Restaurant(
        id: UUID().uuidString,
        name: "Pizza Place",
        category: "italian",
        createdAt: now,
        updatedAt: now
    )
}
```

## Repository in SwiftUI

### ViewModel Pattern

```swift
@Observable
@MainActor
final class RestaurantListViewModel {
    var restaurants: [Restaurant] = []
    var isLoading = false
    var error: Error?

    private let repository: FirestoreRepository<Restaurant>

    init() throws {
        self.repository = try FirestoreRepository(collectionPath: "restaurants")
    }

    func loadRestaurants() async {
        isLoading = true
        do {
            restaurants = try await repository.fetchAll()
        } catch {
            self.error = error
        }
        isLoading = false
    }

    func addRestaurant(_ restaurant: Restaurant) async {
        do {
            try await repository.save(restaurant)
            await loadRestaurants()
        } catch {
            self.error = error
        }
    }
}
```

### View

```swift
struct RestaurantListView: View {
    @State private var viewModel: RestaurantListViewModel

    init() throws {
        _viewModel = State(wrappedValue: try RestaurantListViewModel())
    }

    var body: some View {
        List(viewModel.restaurants) { restaurant in
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.headline)
                Text(restaurant.category)
                    .font(.caption)
            }
        }
        .task {
            await viewModel.loadRestaurants()
        }
    }
}
```

## Error Handling

```swift
do {
    let restaurant = try await repository.fetch(id: "abc123")
} catch FirebaseError.documentNotFound {
    print("Restaurant not found")
} catch FirebaseError.permissionDenied {
    print("Access denied - check security rules")
} catch {
    print("Error: \(error)")
}
```

## Best Practices

### Use Specific Collection Paths

```swift
// Good - specific collection
let restaurantRepo = try FirestoreRepository<Restaurant>(
    collectionPath: "restaurants"
)

// Bad - generic collection name
let repo = try FirestoreRepository<Item>(collectionPath: "items")
```

### Batch Operations

For multiple writes, consider using Firestore batch operations:

```swift
// Save multiple restaurants efficiently
for restaurant in restaurants {
    try await repository.save(restaurant)
}
```

### Indexing

For queries with `orderBy` and `where`, create composite indexes in Firebase Console.

### Pagination

For large collections, implement pagination:

```swift
// Fetch first page
let firstPage = try await repository.query(
    orderBy: "createdAt",
    descending: true,
    limit: 20
)
```

## See Also

- ``Repository``
- ``FirestoreRepository``
- ``FirestoreDocument``
- <doc:/ARCFirebaseCore/SecurityBestPractices>
