import CoreData
import UIKit

protocol TrackerStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: TrackerProtocol, category: CategoryCoreData, schedule: ScheduleCoreData)
    func update(_ record: NSManagedObject, _ tracker: TrackerProtocol)
    func delete(_ record: NSManagedObject)
}

final class TrackerStore {
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

// MARK: - TrackerStoreProtocol

extension TrackerStore: TrackerStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }

    func add(_ record: TrackerProtocol, category: CategoryCoreData, schedule: ScheduleCoreData) {
        let entity = TrackerCoreData(context: context)
        entity.id = UUID()
        entity.title = record.title
        entity.emoji = record.emoji
        entity.color = record.color
        entity.category = category
        entity.schedule = schedule
        saveContext()
    }

    func update(_ record: NSManagedObject, _ tracker: TrackerProtocol) {
        let entity = record as? TrackerCoreData
        entity?.title = tracker.title
        entity?.emoji = tracker.emoji
        entity?.color = tracker.color
        saveContext()
    }

    func delete(_ record: NSManagedObject) {
        context.delete(record)
        saveContext()
    }
}
