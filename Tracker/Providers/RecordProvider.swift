import CoreData

struct RecordStoreUpdate {
    let insertedIndexes: Set<IndexPath>
    let deletedIndexes: Set<IndexPath>
}

protocol RecordProviderDelegate: AnyObject {
    func didUpdate(_ update: RecordStoreUpdate)
}

protocol RecordProviderProtocol {
    var delegate: RecordProviderDelegate? { get set }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> RecordCoreData
    func addRecord(by id: UUID, _ record: RecordProtocol)
    func deleteRecord(_ record: RecordCoreData)
}

final class RecordProvider: NSObject {
    enum ProviderError: Error {
        case failedToInitializeContext
    }

    weak var delegate: RecordProviderDelegate?

    private let context: NSManagedObjectContext
    private let recordStore: TrackerRecordStoreProtocol
    private let trackerProvider: TrackerProviderProtocol
    private var insertedIndexes: Set<IndexPath>?
    private var deletedIndexes: Set<IndexPath>?

    private lazy var fetchedResultsController: NSFetchedResultsController<RecordCoreData> = {
        let fetchRequest = NSFetchRequest<RecordCoreData>(entityName: "RecordCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(_ recordStore: TrackerRecordStoreProtocol, _ trackerProvider: TrackerProviderProtocol) throws {
        guard let context = recordStore.managedObjectContext else {
            throw ProviderError.failedToInitializeContext
        }
        self.context = context
        self.recordStore = recordStore
        self.trackerProvider = trackerProvider
    }
}

// MARK: - DataProviderProtocol

extension RecordProvider: RecordProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func object(at indexPath: IndexPath) -> RecordCoreData {
        fetchedResultsController.object(at: indexPath)
    }

    func addRecord(by id: UUID, _ record: RecordProtocol) {
        guard let tracker = trackerProvider.find(by: id) else { return }
        recordStore.add(record, tracker)
    }

    func deleteRecord(_ record: RecordCoreData) {
        recordStore.delete(record)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension RecordProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexes,
              let deletedIndexes
        else { return }

        delegate?.didUpdate(RecordStoreUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes
            )
        )
        self.insertedIndexes = nil
        self.deletedIndexes = nil
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
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath)
            }
        default:
            break
        }
    }
}
