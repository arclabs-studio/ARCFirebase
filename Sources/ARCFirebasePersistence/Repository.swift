import Foundation

/// Generic repository protocol for data persistence.
///
/// Defines the basic CRUD operations that any persistence layer should implement.
///
/// ## Topics
///
/// ### CRUD Operations
/// - ``fetch(id:)``
/// - ``fetchAll()``
/// - ``save(_:)``
/// - ``update(_:)``
/// - ``delete(id:)``
public protocol Repository {
    /// The type of entity this repository manages.
    associatedtype Entity: Identifiable & Codable

    /// Fetches a single entity by ID.
    ///
    /// - Parameter id: The entity's unique identifier.
    /// - Returns: The entity, or `nil` if not found.
    /// - Throws: Persistence errors.
    func fetch(id: Entity.ID) async throws -> Entity?

    /// Fetches all entities.
    ///
    /// - Returns: An array of all entities.
    /// - Throws: Persistence errors.
    func fetchAll() async throws -> [Entity]

    /// Saves a new entity.
    ///
    /// - Parameter entity: The entity to save.
    /// - Throws: Persistence errors.
    func save(_ entity: Entity) async throws

    /// Updates an existing entity.
    ///
    /// - Parameter entity: The entity with updated values.
    /// - Throws: Persistence errors.
    func update(_ entity: Entity) async throws

    /// Deletes an entity by ID.
    ///
    /// - Parameter id: The ID of the entity to delete.
    /// - Throws: Persistence errors.
    func delete(id: Entity.ID) async throws
}
