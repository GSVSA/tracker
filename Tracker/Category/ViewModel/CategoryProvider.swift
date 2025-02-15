import CoreData

struct CategoryStoreUpdate {
    let insertedIndexes: Set<IndexPath>
    let deletedIndexes: Set<IndexPath>
    let updatedIndexes: Set<IndexPath>
}

typealias Binding<T> = (T) -> Void

protocol CategoryProviderProtocol {
    var didUpdate: Binding<CategoryStoreUpdate>? { get set }
    var didNumberOfRowsUpdate: Binding<Int>? { get set }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func find(at: IndexPath) -> CategoryCoreData
    func find(by category: CategoryProtocol) -> CategoryCoreData?
    func addOrUpdateRecord(_ record: CategoryProtocol, at indexPath: IndexPath?)
    func deleteRecord(at indexPath: IndexPath)
}

final class CategoryProvider: NSObject {
    enum ProviderError: Error {
        case failedToInitializeContext
    }

    var didUpdate: Binding<CategoryStoreUpdate>?
    var didNumberOfRowsUpdate: Binding<Int>?

    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStoreProtocol
    private var insertedIndexes: Set<IndexPath>?
    private var deletedIndexes: Set<IndexPath>?
    private var updatedIndexes: Set<IndexPath>?

    private lazy var fetchedResultsController: NSFetchedResultsController<CategoryCoreData> = {
        let fetchRequest = NSFetchRequest<CategoryCoreData>(entityName: "CategoryCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: false)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(_ categoryStore: TrackerCategoryStoreProtocol) throws {
        guard let context = categoryStore.managedObjectContext else {
            throw ProviderError.failedToInitializeContext
        }
        self.context = context
        self.categoryStore = categoryStore
    }
}

// MARK: - DataProviderProtocol

extension CategoryProvider: CategoryProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        let numberOfRows = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        didNumberOfRowsUpdate?(numberOfRows)
        return numberOfRows
    }

    func find(at indexPath: IndexPath) -> CategoryCoreData {
        fetchedResultsController.object(at: indexPath)
    }

    func find(by category: CategoryProtocol) -> CategoryCoreData? {
        fetchedResultsController.fetchedObjects?.first(where: { $0.title == category.title })
    }

    func addOrUpdateRecord(_ record: CategoryProtocol, at indexPath: IndexPath? = nil) {
        if find(by: record) != nil { return }

        guard let indexPath else {
            categoryStore.add(record)
            return
        }

        let existedEntity = find(at: indexPath)
        categoryStore.update(existedEntity, record)
    }

    func deleteRecord(at indexPath: IndexPath) {
        let record = find(at: indexPath)
        categoryStore.delete(record)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension CategoryProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
        updatedIndexes = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexes,
              let updatedIndexes,
              let deletedIndexes
        else { return }

        didUpdate?(CategoryStoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            updatedIndexes: updatedIndexes
        ))
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexes?.insert(indexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath)
            }
        default:
            break
        }
    }
}
