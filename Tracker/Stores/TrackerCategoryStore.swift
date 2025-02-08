import CoreData
import UIKit

protocol TrackerCategoryStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: CategoryProtocol)
    func update(_ record: NSManagedObject, _ tracker: CategoryProtocol)
    func delete(_ record: NSManagedObject)
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

    func add(_ record: CategoryProtocol) {
        let entity = CategoryCoreData(context: context)
        entity.title = record.title
        saveContext()
    }

    func update(_ record: NSManagedObject, _ category: CategoryProtocol) {
        let entity = record as? CategoryCoreData
        entity?.title = category.title
        saveContext()
    }

    func delete(_ record: NSManagedObject) {
        context.delete(record)
        saveContext()
    }
}
