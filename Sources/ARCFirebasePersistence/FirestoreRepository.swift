import Foundation
import FirebaseFirestore
import ARCFirebaseCore
import ARCLogger

/// Generic Firestore repository implementation.
///
/// `FirestoreRepository` provides a type-safe, protocol-based interface
/// to Firestore collections.
///
/// ## Usage
///
/// ```swift
/// struct Restaurant: Identifiable, Codable {
///     let id: String
///     let name: String
///     let category: String
/// }
///
/// let repository = FirestoreRepository<Restaurant>(collectionPath: "restaurants")
///
/// // Save
/// try await repository.save(restaurant)
///
/// // Fetch
/// let restaurant = try await repository.fetch(id: "abc123")
///
/// // Fetch all
/// let allRestaurants = try await repository.fetchAll()
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init(collectionPath:)``
///
/// ### CRUD Operations
/// - ``fetch(id:)``
/// - ``fetchAll()``
/// - ``save(_:)``
/// - ``update(_:)``
/// - ``delete(id:)``
///
/// ### Advanced Queries
/// - ``query(where:isEqualTo:)``
/// - ``query(orderBy:descending:limit:)``
///
/// ### Guide
/// - <doc:FirestorePatterns>
public final class FirestoreRepository<Entity: Identifiable & Codable>: Repository where Entity.ID == String {

    // MARK: - Properties

    private let collectionPath: String
    private let db: Firestore
    private let logger: ARCLogger

    private var collection: CollectionReference {
        db.collection(collectionPath)
    }

    // MARK: - Initialization

    /// Creates a repository for a Firestore collection.
    ///
    /// - Parameter collectionPath: The path to the Firestore collection (e.g., "restaurants").
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init(collectionPath: String) throws {
        try FirebaseManager.ensureConfigured()

        self.collectionPath = collectionPath
        self.db = Firestore.firestore()
        self.logger = ARCLogger(category: "Firestore[\(collectionPath)]")

        logger.info("Repository initialized for collection: \(collectionPath)")
    }

    // MARK: - Repository Protocol

    public func fetch(id: String) async throws -> Entity? {
        logger.debug("Fetching document: \(id)")

        do {
            let document = try await collection.document(id).getDocument()

            guard document.exists else {
                logger.debug("Document not found: \(id)")
                return nil
            }

            let entity = try document.data(as: Entity.self)
            logger.debug("Fetched document: \(id)")
            return entity

        } catch {
            logger.error("Failed to fetch document \(id): \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func fetchAll() async throws -> [Entity] {
        logger.debug("Fetching all documents")

        do {
            let snapshot = try await collection.getDocuments()
            let entities = try snapshot.documents.compactMap { document in
                try document.data(as: Entity.self)
            }

            logger.debug("Fetched \(entities.count) documents")
            return entities

        } catch {
            logger.error("Failed to fetch all documents: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func save(_ entity: Entity) async throws {
        logger.debug("Saving document: \(entity.id)")

        do {
            try collection.document(entity.id).setData(from: entity)
            logger.info("Saved document: \(entity.id)")

        } catch {
            logger.error("Failed to save document \(entity.id): \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func update(_ entity: Entity) async throws {
        logger.debug("Updating document: \(entity.id)")

        do {
            try collection.document(entity.id).setData(from: entity, merge: true)
            logger.info("Updated document: \(entity.id)")

        } catch {
            logger.error("Failed to update document \(entity.id): \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func delete(id: String) async throws {
        logger.debug("Deleting document: \(id)")

        do {
            try await collection.document(id).delete()
            logger.info("Deleted document: \(id)")

        } catch {
            logger.error("Failed to delete document \(id): \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    // MARK: - Advanced Queries

    /// Queries documents where a field equals a value.
    ///
    /// ```swift
    /// let italianRestaurants = try await repository.query(
    ///     where: "category",
    ///     isEqualTo: "italian"
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - field: The field name to query.
    ///   - value: The value to match.
    /// - Returns: Array of matching entities.
    /// - Throws: Firestore errors.
    public func query(where field: String, isEqualTo value: Any) async throws -> [Entity] {
        logger.debug("Querying where \(field) == \(value)")

        do {
            let snapshot = try await collection.whereField(field, isEqualTo: value).getDocuments()
            let entities = try snapshot.documents.compactMap { document in
                try document.data(as: Entity.self)
            }

            logger.debug("Query returned \(entities.count) documents")
            return entities

        } catch {
            logger.error("Query failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    /// Queries documents with ordering and limit.
    ///
    /// ```swift
    /// let topRestaurants = try await repository.query(
    ///     orderBy: "rating",
    ///     descending: true,
    ///     limit: 10
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - field: The field to order by.
    ///   - descending: Whether to sort in descending order.
    ///   - limit: Maximum number of documents to return.
    /// - Returns: Array of ordered entities.
    /// - Throws: Firestore errors.
    public func query(orderBy field: String, descending: Bool = false, limit: Int? = nil) async throws -> [Entity] {
        logger.debug("Querying orderBy \(field), limit: \(limit ?? 0)")

        do {
            var query: Query = collection.order(by: field, descending: descending)

            if let limit = limit {
                query = query.limit(to: limit)
            }

            let snapshot = try await query.getDocuments()
            let entities = try snapshot.documents.compactMap { document in
                try document.data(as: Entity.self)
            }

            logger.debug("Query returned \(entities.count) documents")
            return entities

        } catch {
            logger.error("Query failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }
}
