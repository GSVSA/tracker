import CoreData
import UIKit

protocol TrackerCategoryStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ category: CategoryProtocol)
    func update(_ entity: NSManagedObject, _ category: CategoryProtocol)
    func delete(_ entity: NSManagedObject)
}

final class TrackerCategoryStore {
    private var container: PersistentContainer
    private var context: NSManagedObjectContext

    init(container: PersistentContainer) {
        self.container = container
        self.context = container.persistentContainer.viewContext
    }

    convenience init() {
        self.init(container: PersistentContainer.shared)
    }

    private func saveContext() {
        container.saveContext()
    }
}

// MARK: - TrackerCategoryStoreProtocol

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }

    func add(_ category: CategoryProtocol) {
        let entity = CategoryCoreData(context: context)
        entity.title = category.title
        saveContext()
    }

    func update(_ entity: NSManagedObject, _ category: CategoryProtocol) {
        let entity = entity as? CategoryCoreData
        entity?.title = category.title
        saveContext()
    }

    func delete(_ entity: NSManagedObject) {
        context.delete(entity)
        saveContext()
    }
}
