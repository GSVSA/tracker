import UIKit

final class TrackersListViewController: UIViewController {
    private var categories: [Category] = mockedCategories
    private var completedTrackers: [Record] = mockedCompletedTrackers
    private var filters: Filters = .init()

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let columnsCount: CGFloat = 2
    private let cellGap: CGFloat = 9

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()

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
        collectionView.register(CollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeader.reuseIdentifier)
        collectionView.backgroundColor = .Theme.background
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setEmptyBlockVisible(categories.isEmpty)
        filterCategoriesByDate()
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

    private func setEmptyBlockVisible(_ isVisible: Bool) {
        emptyBlock.isHidden = !isVisible
    }

    private func filterCategoriesByDate() {
        guard let date = filters.date else { return }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        let weekdayName = formatter.string(from: date).lowercased()

        let filteredCategories = mockedCategories.map { category in
            let trackers = category.trackers.filter { tracker in
                tracker.schedule.selectedDays.contains(where: { $0.translated.lowercased() == weekdayName })
            }
            return Category(title: category.title, trackers: trackers)
        }.filter { !$0.trackers.isEmpty }
        categories = filteredCategories
        collectionView.reloadData()
    }

    private func isFutureDate(_ dateString: String) -> Bool {
        let dateFormatter = dateFormatter
        guard let inputDate = dateFormatter.date(from: dateString) else {
            print("Невозможно преобразовать строку в дату")
            return false
        }
        let currentDate = Calendar.current.startOfDay(for: Date())
        return inputDate > currentDate
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

// MARK: - extensions

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

extension TrackersListViewController: UICollectionViewDataSource {
    // количество секций
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }

    // количество ячеек в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt: IndexPath) -> UICollectionViewCell {
        // сама ячейка
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersListCell.reuseIdentifier, for: cellForItemAt)
        guard let trackersListCell = cell as? TrackersListCell else {
            return UICollectionViewCell()
        }
        configCell(trackersListCell, for: cellForItemAt)
        return trackersListCell
    }
    
    private func configCell(_ cell: TrackersListCell, for indexPath: IndexPath) {
        cell.delegate = self
        let tracker = categories[indexPath.section].trackers[indexPath.item]

        guard let date = filters.date else { return }
        let dateString = dateFormatter.string(from: date)
        let completed = completedTrackers.filter({ $0.trackerID == tracker.id })
        let todayCompleted = completed.filter({ $0.date == dateString })
        let dateIsFuture = isFutureDate(dateString)
        cell.setup(.init(
            id: tracker.id,
            title: tracker.title,
            color: tracker.color,
            emoji: tracker.emoji,
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
        collectionHeader.titleLabel.text = categories[indexPath.section].title
        return collectionHeader
    }
}

extension TrackersListViewController: TrackTrackerListCellDelegate {
    func didTapCounter(id trackerId: UUID) {
        guard let date = filters.date else { return }
        let dateString = dateFormatter.string(from: date)
        guard let indexOfCompleted = completedTrackers.firstIndex(where: { $0.trackerID == trackerId && $0.date == dateString }) else {
            let record = Record(trackerID: trackerId, date: dateString)
            completedTrackers.append(record)
            collectionView.reloadData()
            return
        }
        completedTrackers.remove(at: indexOfCompleted)
        collectionView.reloadData()
    }
}
