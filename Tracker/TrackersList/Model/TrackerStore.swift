import CoreData
import UIKit

protocol TrackerStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    var list: [TrackerCoreData] { get }
    func list(by predicate: NSPredicate) -> [TrackerCoreData]
    func find(by id: UUID) -> TrackerCoreData?
    func add(_ record: TrackerProtocol, category: CategoryCoreData, schedule: ScheduleCoreData)
    func update(_ record: NSManagedObject, _ tracker: TrackerProtocol, category: CategoryCoreData, schedule: ScheduleCoreData)
    func delete(_ record: NSManagedObject)
    func setPinned(_ record: NSManagedObject, _ state: Bool)
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

    var list: [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    func list(by predicate: NSPredicate) -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    func find(by id: UUID) -> TrackerCoreData? {
        list.first(where: { $0.id == id })
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

    func update(_ record: NSManagedObject, _ tracker: TrackerProtocol, category: CategoryCoreData, schedule: ScheduleCoreData) {
        let entity = record as? TrackerCoreData
        entity?.title = tracker.title
        entity?.emoji = tracker.emoji
        entity?.color = tracker.color
        entity?.category = category
        entity?.schedule = schedule
        saveContext()
    }

    func setPinned(_ record: NSManagedObject, _ state: Bool) {
        let entity = record as? TrackerCoreData
        entity?.pinned = state
        saveContext()
    }

    func delete(_ record: NSManagedObject) {
        context.delete(record)
        saveContext()
    }
}
