import CoreData

struct ScheduleStoreUpdate {
    let insertedIndexes: Set<IndexPath>
    let deletedIndexes: Set<IndexPath>
    let updatedIndexes: Set<IndexPath>
}

protocol ScheduleProviderDelegate: AnyObject {
    func didUpdate(_ update: ScheduleStoreUpdate)
}

protocol ScheduleProviderProtocol {
    var delegate: ScheduleProviderDelegate? { get set }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func find(at: IndexPath) -> ScheduleCoreData
    func addRecord(_ schedule: ScheduleProtocol) -> ScheduleCoreData
    func updateRecord(at indexPath: IndexPath, _ schedule: ScheduleProtocol)
    func deleteRecord(at indexPath: IndexPath)
}

final class ScheduleProvider: NSObject {
    enum ProviderError: Error {
        case failedToInitializeContext
    }

    weak var delegate: ScheduleProviderDelegate?

    private let context: NSManagedObjectContext
    private let scheduleStore: TrackerScheduleStoreProtocol
    private var insertedIndexes: Set<IndexPath>?
    private var deletedIndexes: Set<IndexPath>?
    private var updatedIndexes: Set<IndexPath>?

    private lazy var fetchedResultsController: NSFetchedResultsController<ScheduleCoreData> = {
        let fetchRequest = NSFetchRequest<ScheduleCoreData>(entityName: "ScheduleCoreData")
        fetchRequest.sortDescriptors = []
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(_ scheduleStore: TrackerScheduleStoreProtocol) throws {
        guard let context = scheduleStore.managedObjectContext else {
            throw ProviderError.failedToInitializeContext
        }
        self.context = context
        self.scheduleStore = scheduleStore
    }

    private func performFetch() {
        try? fetchedResultsController.performFetch()
    }
}

// MARK: - DataProviderProtocol

extension ScheduleProvider: ScheduleProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func find(at indexPath: IndexPath) -> ScheduleCoreData {
        fetchedResultsController.object(at: indexPath)
    }

    func addRecord(_ schedule: ScheduleProtocol) -> ScheduleCoreData {
        return scheduleStore.add(schedule)
    }

    func updateRecord(at indexPath: IndexPath, _ schedule: ScheduleProtocol) {
        let entity = find(at: indexPath)
        scheduleStore.update(entity, schedule)
    }

    func deleteRecord(at indexPath: IndexPath) {
        let record = find(at: indexPath)
        scheduleStore.delete(record)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ScheduleProvider: NSFetchedResultsControllerDelegate {
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

        delegate?.didUpdate(ScheduleStoreUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                updatedIndexes: updatedIndexes
            )
        )
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
