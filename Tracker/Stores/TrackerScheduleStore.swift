import CoreData
import UIKit

protocol TrackerScheduleStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ schedule: ScheduleProtocol) -> ScheduleCoreData
    func update(_ record: NSManagedObject, _ schedule: ScheduleProtocol)
    func delete(_ record: NSManagedObject)
}

final class TrackerScheduleStore {
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

// MARK: - TrackerScheduleStoreProtocol

extension TrackerScheduleStore: TrackerScheduleStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }

    func add(_ schedule: ScheduleProtocol) -> ScheduleCoreData {
        let entity = ScheduleCoreData(context: context)
        entity.selectedDays = schedule.selectedDays as? NSObject
        saveContext()
        return entity
    }

    func update(_ record: NSManagedObject, _ schedule: ScheduleProtocol) {
        let entity = record as? ScheduleCoreData
        entity?.selectedDays = schedule.selectedDays as? NSObject
        saveContext()
    }

    func delete(_ record: NSManagedObject) {
        context.delete(record)
        saveContext()
    }
}
