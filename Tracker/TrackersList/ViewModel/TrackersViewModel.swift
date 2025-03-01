import UIKit

struct TrackerInfo {
    let id: UUID?
    let tracker: TrackerProtocol
    let selectedDays: [Weekday]
    let category: CategoryProtocol
    let recordsCount: Int

    init(id: UUID? = nil, tracker: TrackerProtocol, selectedDays: [Weekday], category: CategoryProtocol, recordsCount: Int = 0) {
        self.id = id
        self.tracker = tracker
        self.selectedDays = selectedDays
        self.category = category
        self.recordsCount = recordsCount
    }
}

protocol TrackersViewModelProtocol {
    var filtersModel: FiltersModelProtocol { get }
    var didUpdate: (() -> Void)? { get set }
    var didNumberOfRowsUpdate: Binding<Int>? { get set }
    var navigateToEdition: ((TrackerInfo) -> Void)? { get set }
    var canBeFiltered: Bool { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func find(at indexPath: IndexPath) -> TrackerCoreData?
    func filter()
    func search(_ text: String?)
    func getSection(_ section: Int) -> SectionInfo?
    func getConfigCell(at indexPath: IndexPath) -> TrackersListCellModel?
    func updateCounter(at id: UUID)
    func add(_ trackerInfo: TrackerInfo)
    func update(_ trackerInfo: TrackerInfo)
    func didDateChange(_ date: Date)
    func edit(at indexPath: IndexPath)
    func delete(at indexPath: IndexPath)
    func togglePinned(at indexPath: IndexPath)
}

final class TrackersViewModel {
    var didUpdate: (() -> Void)?
    var didNumberOfRowsUpdate: Binding<Int>?
    var navigateToEdition: ((TrackerInfo) -> Void)?

    private(set) lazy var filtersModel: FiltersModelProtocol = FiltersStore()
    private lazy var trackersModel = TrackerStore()
    private lazy var recordModel = TrackerRecordStore()
    private lazy var categoryModel = TrackerCategoryStore()
    private lazy var scheduleModel = TrackerScheduleStore()

    private lazy var trackerProvider: TrackerProviderProtocol? = {
        do {
            try trackerProvider = TrackerProvider(trackersModel, filters: filtersModel.object)
            trackerProvider?.didUpdate = { [weak self] in
                self?.didUpdate?()
            }
            return trackerProvider
        } catch {
            return nil
        }
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()

    private func isFutureDate(_ dateString: String) -> Bool {
        guard let inputDate = dateFormatter.date(from: dateString) else { return false }
        let currentDate = Calendar.current.startOfDay(for: Date())
        return inputDate > currentDate
    }

    private func find(by id: UUID) -> TrackerCoreData? {
        trackerProvider?.find(by: id)
    }
}

extension TrackersViewModel: TrackersViewModelProtocol {
    var canBeFiltered: Bool {
        (trackerProvider?.listByDate.count ?? 0) > 0
    }

    var numberOfSections: Int {
        let numberOfSections = trackerProvider?.sections.count ?? 0
        didNumberOfRowsUpdate?(numberOfSections)
        return numberOfSections
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        trackerProvider?.sections[section].numberOfObjects ?? 0
    }

    func find(at indexPath: IndexPath) -> TrackerCoreData? {
        trackerProvider?.find(at: indexPath)
    }

    func filter() {
        trackerProvider?.filter(filtersModel.object)
    }

    func search(_ text: String?) {
        trackerProvider?.filter(text)
    }

    func getSection(_ section: Int) -> SectionInfo? {
        trackerProvider?.sections[section]
    }

    func getConfigCell(at indexPath: IndexPath) -> TrackersListCellModel? {
        guard let tracker = find(at: indexPath),
              let date = filtersModel.date
        else { return nil }

        let dateString = dateFormatter.string(from: date)
        guard let completed = tracker.records as? Set<RecordCoreData> else { return nil }
        let todayCompleted = completed.filter({ $0.date == dateString })
        let dateIsFuture = isFutureDate(dateString)
        guard let title = tracker.title,
              let color = tracker.color as? UIColor,
              let emoji = tracker.emoji,
              let id = tracker.id
        else { return nil }

        return .init(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            count: completed.count,
            completed: todayCompleted.count > 0,
            disabled: dateIsFuture,
            pinned: tracker.pinned
        )
    }

    func updateCounter(at id: UUID) {
        guard let date = filtersModel.date else { return }
        let dateString = dateFormatter.string(from: date)

        guard let tracker = find(by: id),
              let records = tracker.records as? Set<RecordCoreData>
        else { return }

        guard let completedRecord = records.first(where: { $0.date == dateString }) else {
            let record = Record(date: dateString)
            recordModel.add(record, tracker)
            return
        }
        recordModel.delete(completedRecord)
    }

    func add(_ trackerInfo: TrackerInfo) {
        let tracker = trackerInfo.tracker
        let category = trackerInfo.category
        guard let categoryRecord = categoryModel.find(by: category) else { return }
        let selectedDays = trackerInfo.selectedDays
        let schedule = Schedule(selectedDays: selectedDays.count > 0
            ? selectedDays.map { $0.rawValue }
            : nil)
        let scheduleRecord = scheduleModel.add(schedule)
        trackerProvider?.addRecord(tracker, category: categoryRecord, schedule: scheduleRecord)
    }

    func update(_ trackerInfo: TrackerInfo) {
        let category = trackerInfo.category

        guard let trackerId = trackerInfo.id,
              let trackerRecord = find(by: trackerId),
              let categoryRecord = categoryModel.find(by: category)
        else { return }

        let tracker = trackerInfo.tracker
        let selectedDays = trackerInfo.selectedDays
        let schedule = Schedule(selectedDays: selectedDays.count > 0
            ? selectedDays.map { $0.rawValue }
            : nil)
        let scheduleRecord = trackerRecord.schedule ?? scheduleModel.add(schedule)
        scheduleModel.update(scheduleRecord, schedule)

        trackerProvider?.updateRecord(
            by: trackerId,
            tracker,
            category: categoryRecord,
            schedule: scheduleRecord
        )
    }

    func didDateChange(_ date: Date) {
        filtersModel.setDate(date)
        filter()
    }

    func togglePinned(at indexPath: IndexPath) {
        guard let trackerEntity = find(at: indexPath),
              let trackerId = trackerEntity.id
        else { return }
        trackerProvider?.setPinned(by: trackerId, !trackerEntity.pinned)
    }

    func edit(at indexPath: IndexPath) {
        guard let trackerEntity = find(at: indexPath),
              let title = trackerEntity.title,
              let color = trackerEntity.color as? UIColor,
              let emoji = trackerEntity.emoji,
              let id = trackerEntity.id,
              let categoryTitle = trackerEntity.category?.title
        else { return }
        let tracker = Tracker(
            title: title,
            color: color,
            emoji: emoji,
            pinned: trackerEntity.pinned
        )
        let selectedDaysString = trackerEntity.schedule?.selectedDays as? [String]
        let selectedDays = selectedDaysString?.count == 0
            ? []
            : selectedDaysString?.compactMap(Weekday.init(rawValue:)) ?? [];
        let category = Category(title: categoryTitle)
        let trackerInfo = TrackerInfo(
            id: id,
            tracker: tracker,
            selectedDays: selectedDays,
            category: category,
            recordsCount: trackerEntity.records?.count ?? 0
        )
        navigateToEdition?(trackerInfo)
    }

    func delete(at indexPath: IndexPath) {
        guard find(at: indexPath)?.id != nil else { return }
        trackerProvider?.deleteRecord(at: indexPath)
        didUpdate?()
    }
}
