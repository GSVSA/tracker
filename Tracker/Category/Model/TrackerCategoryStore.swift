import CoreData

protocol TrackerCategoryStoreProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    var count: Int { get }
    var list: [CategoryCoreData] { get }
    func find(at index: Int) -> CategoryCoreData?
    func find(by category: CategoryProtocol) -> CategoryCoreData?
    func add(_ category: CategoryProtocol)
    func update(_ entity: NSManagedObject, _ category: CategoryProtocol)
    func delete(_ entity: NSManagedObject)
    func addOrUpdate(_ category: CategoryProtocol, at index: Int?)
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

    var count: Int {
        let fetchRequest: NSFetchRequest<CategoryCoreData> = CategoryCoreData.fetchRequest()
        do {
            return try context.fetch(fetchRequest).count
        } catch {
            return 0
        }
    }

    var list: [CategoryCoreData] {
        let fetchRequest: NSFetchRequest<CategoryCoreData> = CategoryCoreData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    func find(at index: Int) -> CategoryCoreData? {
        list[index]
    }

    func find(by category: CategoryProtocol) -> CategoryCoreData? {
        list.first(where: { $0.title == category.title })
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

    func delete(at index: Int) {
        guard let category = find(at: index) else { return }
        delete(category)
    }

    func addOrUpdate(_ category: CategoryProtocol, at index: Int? = nil) {
        if find(by: category) != nil { return }

        guard let index else {
            add(category)
            return
        }

        guard let existedEntity = find(at: index) else { return }
        update(existedEntity, category)
    }
}
