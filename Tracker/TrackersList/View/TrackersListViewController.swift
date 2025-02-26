import UIKit

final class TrackersListViewController: UIViewController {
    private let analyticsService = AnalyticsService()

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let columnsCount: CGFloat = 2
    private let cellGap: CGFloat = 9

    private var viewModel: TrackersViewModelProtocol?
    private var filtersModel: FiltersModelProtocol? { viewModel?.filtersModel }

    private lazy var datePicker: DatePicker = {
        let datePicker = DatePicker()
        filtersModel?.setDate(datePicker.date)
        datePicker.addTarget(self, action: #selector(didDateChange), for: .valueChanged)
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        return datePicker
    }()

    private lazy var emptyBlock: EmptyBlock = {
        let block = EmptyBlock()
        block.setLabel(NSLocalizedString("trackersEmptyState", comment: "Текст отображаемый при отсутствии трекеров на странице"))
        return block
    }()

    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("filtersLabel", comment: "Текст на кнопке фильтров"), for: .normal)
        let titleColor: UIColor = ThemeManager.isLightMode ? .Theme.background : .Theme.contrast
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .Theme.accent
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        button.addTarget(self, action: #selector(didFiltersButtonTap), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Theme.background
        setupNavBar()
        setupViewModel()
        setupCollection()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.open()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.close()
    }

    func initialize(viewModel: TrackersViewModelProtocol) {
        self.viewModel = viewModel
    }

    private func setupViewModel() {
        viewModel?.didUpdate = { [weak self] in
            self?.didUpdate()
        }
        viewModel?.didNumberOfRowsUpdate = { [weak self] numberOfRows in
            self?.didNumberOfRowsUpdate(numberOfRows)
        }
        viewModel?.navigateToEdition = { [weak self] trackerInfo in
            self?.navigateToEdition(with: trackerInfo)
        }
    }

    private func setupCollection() {
        collectionView.register(TrackersListCell.self, forCellWithReuseIdentifier: TrackersListCell.reuseIdentifier)
        collectionView.register(
            CollectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionHeader.reuseIdentifier
        )
        collectionView.backgroundColor = .Theme.background
        collectionView.contentInset.bottom = 60
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: "plus")
        navigationItem.leftBarButtonItem?.action = #selector(didNewTrackerTap)
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.tintColor = .Theme.contrast

        let datePickerBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePickerBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 70).isActive = true
        navigationItem.rightBarButtonItem = datePickerBarButtonItem

        navigationItem.title = NSLocalizedString("trackersTitle", comment: "Заголовок страницы со списком трекеров")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = UISearchController()
        navigationItem.searchController?.searchBar.placeholder = NSLocalizedString("searchInputPlaceholder", comment: "Плейсхолдер для поля поиска")
    }

    @objc
    private func didNewTrackerTap() {
        analyticsService.click(item: .add_track)
        let view = NewTrackerViewController()
        view.didAddTracker = { [weak self] trackerInfo in
            self?.viewModel?.add(trackerInfo)
        }
        let navController = UINavigationController(rootViewController: view)
        self.present(navController, animated: true)
    }

    @objc
    private func didFiltersButtonTap() {
        analyticsService.click(item: .filter)
        guard let filtersModel = filtersModel else { return }
        let viewModel = FiltersViewModel(model: filtersModel)
        let view = FiltersViewController()
        view.initialize(viewModel: viewModel)
        view.didChangeValue = { [weak self] selectedType in
            self?.didFilterChange(selectedType)
        }
        let navController = UINavigationController(rootViewController: view)
        self.present(navController, animated: true)
    }

    @objc
    private func didDateChange(_ sender: UIDatePicker) {
        viewModel?.didDateChange(sender.date)
    }

    private func didFilterChange(_ selectedType: FilterType) {
        filtersModel?.setType(selectedType)
        if selectedType == .today {
            let newDate = Date()
            datePicker.setDate(newDate)
            filtersModel?.setDate(newDate)
        }
        viewModel?.filter()
    }

    private func navigateToEdition(with trackerInfo: TrackerInfo) {
        let view = EventSettingsViewController()
        let isIrregular = trackerInfo.selectedDays.count == 0
        view.initialize(isIrregular: isIrregular, trackerInfo: trackerInfo)
        view.didComplete = { [weak self] vc, trackerInfo in
            self?.viewModel?.update(trackerInfo)
            vc.dismiss(animated: true)
        }
        let navController = UINavigationController(rootViewController: view)
        present(navController, animated: true)
    }

    private func didNumberOfRowsUpdate(_ numberOfRows: Int) {
        emptyBlock.isHidden = numberOfRows != 0
    }

    private func updateFiltersVisibility() {
        let canBeFiltered = viewModel?.canBeFiltered ?? false
        filtersButton.isHidden = !canBeFiltered
    }

    private func didUpdate() {
        updateFiltersVisibility()
        collectionView.reloadData()
    }

    private func setupConstraints() {
        [
            collectionView,
            emptyBlock,
            filtersButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            emptyBlock.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
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
        viewModel?.numberOfSections ?? 0
    }

    // количество ячеек в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.numberOfRowsInSection(section) ?? 0
    }

    // сама ячейка
    func collectionView(_ collectionView: UICollectionView, cellForItemAt: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersListCell.reuseIdentifier, for: cellForItemAt)
        guard let trackersListCell = cell as? TrackersListCell else {
            return UICollectionViewCell()
        }
        trackersListCell.delegate = self
        guard let cellConfig = viewModel?.getConfigCell(at: cellForItemAt) else { return trackersListCell }
        trackersListCell.setup(cellConfig)
        return trackersListCell
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
        collectionHeader.titleLabel.text = viewModel?.getSection(indexPath.section)?.title
        return collectionHeader
    }
}

extension TrackersListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let tracker = viewModel?.find(at: indexPath)
        else { return nil }
        let pinOptionLabel = tracker.pinned
            ? NSLocalizedString("unpin", comment: "")
            : NSLocalizedString("pin", comment: "")

        return UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: pinOptionLabel) { [weak self] _ in
                    self?.viewModel?.togglePinned(at: indexPath)
                },
                UIAction(title: NSLocalizedString("edit", comment: "")) { [weak self] _ in
                    self?.analyticsService.click(item: .edit)
                    self?.viewModel?.edit(at: indexPath)
                },
                UIAction(title: NSLocalizedString("delete", comment: ""), attributes: .destructive) { [weak self] _ in
                    self?.analyticsService.click(item: .delete)
                    self?.showDeleteConfirmationAlert(at: indexPath)
                },
            ])
        })
    }

    private func showDeleteConfirmationAlert(at indexPath: IndexPath) {
        let alertController = UIAlertController(
            title: nil,
            message: NSLocalizedString("trackerDeleteConfirmDescription", comment: ""),
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive) { [weak self] _ in
            self?.viewModel?.delete(at: indexPath)
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
}

// MARK: - TrackTrackerListCellDelegate

extension TrackersListViewController: TrackTrackerListCellDelegate {
    func didTapCounter(at id: UUID) {
        analyticsService.click(item: .track)
        viewModel?.updateCounter(at: id)
    }
}
