import UIKit

final class TrackersListViewController: UIViewController {
    private var filters: Filters = .init()

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let columnsCount: CGFloat = 2
    private let cellGap: CGFloat = 9

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()

    private let scheduleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    private lazy var trackerProvider: TrackerProviderProtocol? = {
        let store = TrackerStore()
        do {
            try trackerProvider = TrackerProvider(store, filters: filters)
            trackerProvider?.delegate = self
            return trackerProvider
        } catch {
            showError("Данные недоступны.")
            return nil
        }
    }()

    private lazy var recordModel = TrackerRecordStore()
    private lazy var categoryModel = TrackerCategoryStore()
    private lazy var scheduleModel = TrackerScheduleStore()

    private lazy var emptyBlock: EmptyBlock = {
        let block = EmptyBlock()
        block.setLabel("Что будем отслеживать?")
        return block
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Theme.background
        configureNavBar()
        setupConstraints()

        collectionView.register(TrackersListCell.self, forCellWithReuseIdentifier: TrackersListCell.reuseIdentifier)
        collectionView.register(
            CollectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionHeader.reuseIdentifier
        )
        collectionView.backgroundColor = .Theme.background
        collectionView.dataSource = self
        collectionView.delegate = self

        updateEmptyBlock()
    }

    func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: "plus")
        navigationItem.leftBarButtonItem?.action = #selector(createTracker)
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.tintColor = .Theme.contrast

        let datePicker = DatePicker()
        setDate(datePicker.date)
        datePicker.addTarget(self, action: #selector(didDateChanged), for: .valueChanged)
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        let datePickerBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePickerBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 70).isActive = true
        navigationItem.rightBarButtonItem = datePickerBarButtonItem

        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = UISearchController()
        navigationItem.searchController?.searchBar.placeholder = "Поиск"
    }

    @objc
    func createTracker() {
        let view = NewTrackerViewController()
        view.delegate = self
        let navController = UINavigationController(rootViewController: view)
        self.present(navController, animated: true)
    }

    @objc
    private func didDateChanged(_ sender: UIDatePicker) {
        setDate(sender.date)
        filterCategoriesByDate()
    }

    private func setDate(_ date: Date) {
        self.filters = .init(date: date)
    }

    private func updateEmptyBlock() {
        let isEmpty = (trackerProvider?.numberOfSections ?? 0) == 0
        emptyBlock.isHidden = !isEmpty
    }

    private func filterCategoriesByDate() {
        trackerProvider?.filter(by: filters)
        updateEmptyBlock()
    }

    private func isFutureDate(_ dateString: String) -> Bool {
        guard let inputDate = dateFormatter.date(from: dateString) else {
            print("Невозможно преобразовать строку в дату")
            return false
        }
        let currentDate = Calendar.current.startOfDay(for: Date())
        return inputDate > currentDate
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        present(alert, animated: true, completion: nil)
    }

    private func setupConstraints() {
        [
            collectionView,
            emptyBlock,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            emptyBlock.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // размеры для каждой ячейки
        let columnWidth = collectionView.bounds.width / columnsCount
        let paddingWidth = (columnsCount < 2 ? 0 : cellGap) / (columnsCount > 2 ? 1 : 2)
        return CGSize(width: columnWidth - paddingWidth, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        // минимальный отступ между строками коллекции
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        // минимальный отступ между ячейками
        return cellGap
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 46)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersListViewController: UICollectionViewDataSource {
    // количество секций
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerProvider?.numberOfSections ?? 0
    }

    // количество ячеек в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerProvider?.numberOfRowsInSection(section) ?? 0
    }

    // сама ячейка
    func collectionView(_ collectionView: UICollectionView, cellForItemAt: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersListCell.reuseIdentifier, for: cellForItemAt)
        guard let trackersListCell = cell as? TrackersListCell else {
            return UICollectionViewCell()
        }
        configCell(trackersListCell, for: cellForItemAt)
        return trackersListCell
    }
    
    private func configCell(_ cell: TrackersListCell, for indexPath: IndexPath) {
        cell.delegate = self
        guard let tracker = trackerProvider?.find(at: indexPath) else { return }

        guard let date = filters.date else { return }
        let dateString = dateFormatter.string(from: date)
        guard let completed = tracker.records as? Set<RecordCoreData> else { return }
        let todayCompleted = completed.filter({ $0.date == dateString })
        let dateIsFuture = isFutureDate(dateString)
        guard let title = tracker.title,
              let color = tracker.color as? UIColor,
              let emoji = tracker.emoji,
              let id = tracker.id
        else { return }
        cell.setup(.init(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            count: completed.count,
            completed: todayCompleted.count > 0,
            disabled: dateIsFuture
        ))
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader {
            return UICollectionReusableView()
        }

        guard
            let collectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CollectionHeader.reuseIdentifier,
                for: indexPath
            ) as? CollectionHeader
        else {
            return UICollectionReusableView()
        }
        collectionHeader.titleLabel.text = trackerProvider?.getSection(indexPath.section)?.name
        return collectionHeader
    }
}

// MARK: - TrackTrackerListCellDelegate

extension TrackersListViewController: TrackTrackerListCellDelegate {
    func didTapCounter(at id: UUID) {
        guard let date = filters.date else { return }
        let dateString = dateFormatter.string(from: date)

        guard let tracker = trackerProvider?.find(by: id),
              let records = tracker.records as? Set<RecordCoreData>
        else { return }

        guard let completedRecord = records.first(where: { $0.date == dateString }) else {
            let record = Record(date: dateString)
            recordModel.add(record, tracker)
            return
        }
        recordModel.delete(completedRecord)
    }
}

// MARK: - NewTrackerViewControllerDelegate

extension TrackersListViewController: NewTrackerViewControllerDelegate {
    func didAddTracker(_ vc: NewTrackerViewController, tracker: TrackerProtocol, selectedDays: [Weekday], category: CategoryProtocol) {
        let schedule = Schedule(selectedDays: selectedDays.count > 0
            ? selectedDays.map { $0.rawValue }
            : nil)
        let scheduleRecord = scheduleModel.add(schedule)
        guard let categoryRecord = categoryModel.find(by: category) else { return }
        trackerProvider?.addRecord(tracker, category: categoryRecord, schedule: scheduleRecord)
    }
}

// MARK: - TrackerProviderDelegate

extension TrackersListViewController: TrackerProviderDelegate {
    func didReload() {
        collectionView.reloadData()
    }

    func didUpdate(_ update: StoreUpdate) {
        collectionView.performBatchUpdates {
            if !update.insertedSections.isEmpty {
                collectionView.insertSections(update.insertedSections)
            }
            if !update.deletedSections.isEmpty {
                collectionView.deleteSections(update.deletedSections)
            }
            collectionView.insertItems(at: Array(update.insertedIndexes))
            collectionView.reloadItems(at: Array(update.updatedIndexes))
            collectionView.deleteItems(at: Array(update.deletedIndexes))
        }
        updateEmptyBlock()
    }
}
