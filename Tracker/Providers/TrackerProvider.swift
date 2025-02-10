import CoreData

struct StoreUpdate {
    let insertedIndexes: Set<IndexPath>
    let deletedIndexes: Set<IndexPath>
    let updatedIndexes: Set<IndexPath>
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

protocol TrackerProviderDelegate: AnyObject {
    func didUpdate(_ update: StoreUpdate)
    func didReload()
}

protocol TrackerProviderProtocol {
    var delegate: TrackerProviderDelegate? { get set }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func getSection(_ section: Int) -> NSFetchedResultsSectionInfo?
    func find(at: IndexPath) -> TrackerCoreData
    func find(by id: UUID) -> TrackerCoreData?
    func filter(by filters: Filters)
    func addRecord(_ record: TrackerProtocol, category categoryRecord: CategoryCoreData, schedule scheduleRecord: ScheduleCoreData)
    func updateRecord(at: IndexPath, _ record: TrackerProtocol)
    func deleteRecord(at indexPath: IndexPath)
}

final class TrackerProvider: NSObject {
    enum ProviderError: Error {
        case failedToInitializeContext
    }

    weak var delegate: TrackerProviderDelegate?

    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStoreProtocol
    private var filters: Filters?
    private var insertedIndexes: Set<IndexPath>?
    private var deletedIndexes: Set<IndexPath>?
    private var updatedIndexes: Set<IndexPath>?
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true),
        ]
        fetchRequest.predicate = getPredicate(for: filters)
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    private let scheduleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_EN")
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    init(_ trackerStore: TrackerStoreProtocol, filters: Filters? = nil) throws {
        guard let context = trackerStore.managedObjectContext else {
            throw ProviderError.failedToInitializeContext
        }
        self.context = context
        self.trackerStore = trackerStore
        self.filters = filters
    }

    private func performFetch() {
        try? fetchedResultsController.performFetch()
    }

    private func getPredicate(for filters: Filters?) -> NSPredicate? {
        guard let date = filters?.date
        else { return nil }
        let weekdayName = scheduleDateFormatter.string(from: date).lowercased()
        let isToday = NSPredicate(
            format: "%K CONTAINS %@",
            #keyPath(TrackerCoreData.schedule.selectedDays), weekdayName
        )
        let isIrregular = NSPredicate(
            format: "%K == nil",
            #keyPath(TrackerCoreData.schedule.selectedDays)
        )
        let predicate = NSCompoundPredicate(type: .or, subpredicates: [isIrregular, isToday])
        return predicate
    }

    private func updateFetchRequest(predicate: NSPredicate?) {
        fetchedResultsController.fetchRequest.predicate = predicate
        performFetch()
        delegate?.didReload()
    }
}

// MARK: - DataProviderProtocol

extension TrackerProvider: TrackerProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func filter(by filters: Filters) {
        self.filters = filters
        let predicate = getPredicate(for: filters)
        updateFetchRequest(predicate: predicate)
    }

    func getSection(_ section: Int) -> NSFetchedResultsSectionInfo? {
        fetchedResultsController.sections?[section]
    }

    func find(at indexPath: IndexPath) -> TrackerCoreData {
        fetchedResultsController.object(at: indexPath)
    }

    func find(by id: UUID) -> TrackerCoreData? {
        fetchedResultsController.fetchedObjects?.first(where: { $0.id == id })
    }

    func addRecord(_ record: TrackerProtocol, category categoryRecord: CategoryCoreData, schedule scheduleRecord: ScheduleCoreData) {
        trackerStore.add(record, category: categoryRecord, schedule: scheduleRecord)
    }

    func updateRecord(at indexPath: IndexPath, _ record: TrackerProtocol) {
        let entity = find(at: indexPath)
        trackerStore.update(entity, record)
    }

    func deleteRecord(at indexPath: IndexPath) {
        let record = find(at: indexPath)
        trackerStore.delete(record)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
        updatedIndexes = []
        insertedSections = []
        deletedSections = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexes,
              let updatedIndexes,
              let deletedIndexes,
              let insertedSections,
              let deletedSections
        else { return }

        delegate?.didUpdate(StoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            updatedIndexes: updatedIndexes,
            insertedSections: insertedSections,
            deletedSections: deletedSections
        ))
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
        self.insertedSections = nil
        self.deletedSections = nil
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

    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange sectionInfo: any NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            insertedSections?.insert(sectionIndex)
        case .delete:
            deletedSections?.insert(sectionIndex)
        default:
            break
        }
    }
}
