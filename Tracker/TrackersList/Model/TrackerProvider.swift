import CoreData

protocol TrackerProviderProtocol {
    var didUpdate: (() -> Void)? { get set }
    var listByDate: [TrackerCoreData] { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func getSection(_ section: Int) -> NSFetchedResultsSectionInfo?
    func find(at: IndexPath) -> TrackerCoreData
    func find(by id: UUID) -> TrackerCoreData?
    func filter(_ filters: Filters)
    func addRecord(_ record: TrackerProtocol, category categoryRecord: CategoryCoreData, schedule scheduleRecord: ScheduleCoreData)
    func updateRecord(at: IndexPath, _ record: TrackerProtocol)
    func deleteRecord(at indexPath: IndexPath)
}

final class TrackerProvider: NSObject {
    enum ProviderError: Error {
        case failedToInitializeContext
    }

    var didUpdate: (() -> Void)?

    private let context: NSManagedObjectContext
    private let predicateBuilder = FiltersPredicateBuilder()
    private let trackerStore: TrackerStoreProtocol
    private var filters: Filters?

    private var predicate: NSPredicate? {
        guard let filters = filters else { return nil }
        return predicateBuilder.build(filters: filters)
    }

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true),
        ]
        fetchRequest.predicate = predicate
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
}

// MARK: - DataProviderProtocol

extension TrackerProvider: TrackerProviderProtocol {
    var listByDate: [TrackerCoreData] {
        let filters: Filters = .init(date: filters?.date, type: .all)
        guard let predicate = predicateBuilder.build(filters: filters) else { return [] }
        return trackerStore.list(by: predicate)
    }

    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func filter(_ filters: Filters) {
        self.filters = filters
        fetchedResultsController.fetchRequest.predicate = predicate
        performFetch()
        didUpdate?()
    }

    func getSection(_ section: Int) -> NSFetchedResultsSectionInfo? {
        fetchedResultsController.sections?[section]
    }

    func find(at indexPath: IndexPath) -> TrackerCoreData {
        fetchedResultsController.object(at: indexPath)
    }

    func find(by id: UUID) -> TrackerCoreData? {
        trackerStore.find(by: id)
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
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didUpdate?()
    }
}
