import CoreData

struct SectionInfo {
    let title: String
    let numberOfObjects: Int
    let objects: [TrackerCoreData]
}

protocol TrackerProviderProtocol {
    var didUpdate: (() -> Void)? { get set }
    var listByDate: [TrackerCoreData] { get }
    var sections: [SectionInfo] { get }
    func find(at: IndexPath) -> TrackerCoreData?
    func find(by id: UUID) -> TrackerCoreData?
    func filter(_ filters: Filters)
    func filter(_ search: String?)
    func addRecord(_ record: TrackerProtocol, category: CategoryCoreData, schedule: ScheduleCoreData)
    func updateRecord(by: UUID, _ record: TrackerProtocol, category: CategoryCoreData, schedule: ScheduleCoreData)
    func deleteRecord(at indexPath: IndexPath)
    func setPinned(by id: UUID, _ pinned: Bool)
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
    private var searchString: String?

    private var predicate: NSPredicate? {
        guard let filters = filters else { return nil }
        return predicateBuilder.build(filters: filters, search: searchString, withPinned: false)
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

    private var listByPinned: [TrackerCoreData] {
        let filters: Filters = .init(date: filters?.date, type: .all)
        guard let predicate = predicateBuilder.build(filters: filters, withPinned: true) else { return [] }
        return trackerStore.list(by: predicate)
    }

    private var pureSections: [SectionInfo] {
        let sections = fetchedResultsController.sections ?? []
        return sections.map { section in
            let objects = section.objects as? [TrackerCoreData] ?? []
            return SectionInfo(title: section.name, numberOfObjects: section.numberOfObjects, objects: objects)
        }
    }
}

// MARK: - DataProviderProtocol

extension TrackerProvider: TrackerProviderProtocol {
    var listByDate: [TrackerCoreData] {
        let filters: Filters = .init(date: filters?.date, type: .all)
        guard let predicate = predicateBuilder.build(filters: filters) else { return [] }
        return trackerStore.list(by: predicate)
    }

    var sections: [SectionInfo] {
        if listByPinned.isEmpty {
            return pureSections
        }
        let pinnedSection = SectionInfo(
            title: NSLocalizedString("pinnedSectionLabel", comment: ""),
            numberOfObjects: listByPinned.count,
            objects: listByPinned
        )
        return [pinnedSection] + pureSections
    }

    func filter(_ filters: Filters) {
        self.filters = filters
        fetchedResultsController.fetchRequest.predicate = predicate
        performFetch()
        didUpdate?()
    }

    func filter(_ search: String?) {
        self.searchString = search
        fetchedResultsController.fetchRequest.predicate = predicate
        performFetch()
        didUpdate?()
    }

    func find(at indexPath: IndexPath) -> TrackerCoreData? {
        sections[indexPath.section].objects[indexPath.item]
    }

    func find(by id: UUID) -> TrackerCoreData? {
        trackerStore.find(by: id)
    }

    func addRecord(_ record: TrackerProtocol, category: CategoryCoreData, schedule: ScheduleCoreData) {
        trackerStore.add(record, category: category, schedule: schedule)
    }

    func updateRecord(
        by id: UUID,
        _ record: TrackerProtocol,
        category: CategoryCoreData,
        schedule: ScheduleCoreData
    ) {
        guard let entity = find(by: id) else { return }
        trackerStore.update(entity, record, category: category, schedule: schedule)
    }

    func deleteRecord(at indexPath: IndexPath) {
        guard let record = find(at: indexPath) else { return }
        trackerStore.delete(record)
    }

    func setPinned(by id: UUID, _ pinned: Bool) {
        guard let entity = find(by: id) else { return }
        trackerStore.setPinned(entity, pinned)
    }

    func setPinned(at indexPath: IndexPath, _ pinned: Bool) {
        guard let entity = find(at: indexPath) else { return }
        trackerStore.setPinned(entity, pinned)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didUpdate?()
    }
}
