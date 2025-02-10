import CoreData
import UIKit

protocol TrackerRecordStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: RecordProtocol, _ tracker: NSManagedObject)
    func delete(_ record: NSManagedObject)
}

final class TrackerRecordStore {
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

// MARK: - TrackerRecordStoreProtocol

extension TrackerRecordStore: TrackerRecordStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }

    func add(_ record: RecordProtocol, _ tracker: NSManagedObject) {
        let entity = RecordCoreData(context: context)
        entity.date = record.date
        entity.tracker = tracker as? TrackerCoreData
        saveContext()
    }

    func delete(_ record: NSManagedObject) {
        context.delete(record)
        saveContext()
    }
}
