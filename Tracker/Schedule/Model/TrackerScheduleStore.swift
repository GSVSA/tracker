import CoreData
import UIKit

protocol TrackerScheduleStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    var count: Int { get }
    var list: [ScheduleCoreData] { get }
    func find(at index: Int) -> ScheduleCoreData?
    func add(_ schedule: ScheduleProtocol) -> ScheduleCoreData
    func update(_ entity: NSManagedObject, _ schedule: ScheduleProtocol)
    func update(at index: Int, _ schedule: ScheduleProtocol)
    func delete(_ entity: NSManagedObject)
    func delete(at index: Int)
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

    var count: Int {
        let fetchRequest: NSFetchRequest<ScheduleCoreData> = ScheduleCoreData.fetchRequest()
        do {
            return try context.fetch(fetchRequest).count
        } catch {
            return 0
        }
    }

    var list: [ScheduleCoreData] {
        let fetchRequest: NSFetchRequest<ScheduleCoreData> = ScheduleCoreData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    func find(at index: Int) -> ScheduleCoreData? {
        list[index]
    }

    func add(_ schedule: ScheduleProtocol) -> ScheduleCoreData {
        let entity = ScheduleCoreData(context: context)
        entity.selectedDays = schedule.selectedDays as? NSObject
        saveContext()
        return entity
    }

    func update(_ entity: NSManagedObject, _ schedule: ScheduleProtocol) {
        let entity = entity as? ScheduleCoreData
        entity?.selectedDays = schedule.selectedDays as? NSObject
        saveContext()
    }

    func update(at index: Int, _ schedule: ScheduleProtocol) {
        guard let entity = find(at: index) else { return }
        update(entity, schedule)
    }

    func delete(_ entity: NSManagedObject) {
        context.delete(entity)
        saveContext()
    }

    func delete(at index: Int) {
        guard let schedule = find(at: index) else { return }
        delete(schedule)
    }
}
