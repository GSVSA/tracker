import UIKit

struct SectionInfo {
    let title: String
}

protocol TrackersViewModelProtocol {
    var filtersModel: FiltersModelProtocol { get }
    var didUpdate: (() -> Void)? { get set }
    var didNumberOfRowsUpdate: Binding<Int>? { get set }
    var canBeFiltered: Bool { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func filter()
    func getSection(_ section: Int) -> SectionInfo?
    func getConfigCell(at indexPath: IndexPath) -> TrackersListCellModel?
    func updateCounter(at id: UUID)
    func add(tracker: TrackerProtocol, selectedDays: [Weekday], category: CategoryProtocol)
    func didDateChange(_ date: Date)
}

final class TrackersViewModel {
    var didUpdate: (() -> Void)?
    var didNumberOfRowsUpdate: Binding<Int>?

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

    private func find(at indexPath: IndexPath) -> TrackerCoreData? {
        trackerProvider?.find(at: indexPath)
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
        let numberOfSections = trackerProvider?.numberOfSections ?? 0
        didNumberOfRowsUpdate?(numberOfSections)
        return numberOfSections
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        trackerProvider?.numberOfRowsInSection(section) ?? 0
    }

    func filter() {
        trackerProvider?.filter(filtersModel.object)
    }

    func getSection(_ section: Int) -> SectionInfo? {
        guard let section = trackerProvider?.getSection(section) else { return nil }
        return .init(title: section.name)
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
            disabled: dateIsFuture
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

    func add(tracker: TrackerProtocol, selectedDays: [Weekday], category: CategoryProtocol) {
        let schedule = Schedule(selectedDays: selectedDays.count > 0
            ? selectedDays.map { $0.rawValue }
            : nil)
        let scheduleRecord = scheduleModel.add(schedule)
        guard let categoryRecord = categoryModel.find(by: category) else { return }
        trackerProvider?.addRecord(tracker, category: categoryRecord, schedule: scheduleRecord)
    }

    func didDateChange(_ date: Date) {
        filtersModel.setDate(date)
        filter()
    }
}
