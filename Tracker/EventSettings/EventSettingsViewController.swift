import UIKit

final class EventSettingsViewController: UIViewController {
    var didComplete: ((EventSettingsViewController, TrackerInfo) -> Void)?

    private var initialTrackerInfo: TrackerInfo?

    private var trackerName: String {
        nameInput.textField?.text ?? ""
    }
    private var selectedDays: [Weekday] = []
    private var selectedCategory: String?
    private var hasEmpty: Bool {
        let requiredFieldsEmpty: Bool = trackerName.count == 0
            || selectedCategory == nil
            || emojiCollection.selectedEmoji == nil
            || colorsCollection.selectedColor == nil

        if tableProvider.isIrregular {
            return requiredFieldsEmpty
        }
        return requiredFieldsEmpty || selectedDays.isEmpty
    }

    private var tableProvider = EventSettingsTableProvider()

    private var tableHeightConstraint: NSLayoutConstraint!
    private var emojiCollectionHeightConstraint: NSLayoutConstraint!
    private var colorsCollectionHeightConstraint: NSLayoutConstraint!

    private lazy var contentView = UIView()
    private lazy var tableView = SettingsTable()
    private lazy var emojiCollection: EmojiCollection = {
        let collection = EmojiCollection(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.selectionDelegate = self
        return collection
    }()
    private lazy var colorsCollection: ColorsCollection = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collection = ColorsCollection(frame: .zero, collectionViewLayout: layout)
        collection.selectionDelegate = self
        return collection
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Theme.contrast
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()

    private lazy var nameInput: ValidationTextFieldWrapper = {
        let textField = TextField()
        textField.placeholder = "Введите название трекера"
        let errorWrapper = ValidationTextFieldWrapper(textField)
        errorWrapper.delegate = self
        return errorWrapper
    }()

    private lazy var cancelButton: Button = {
        let button = DangerButton()
        button.setTitle("Отменить", for: .normal)
        button.addTarget(self, action: #selector(didCancelTapped), for: .touchUpInside)
        return button
    }()

    private lazy var createButton: Button = {
        let button = Button()
        button.setTitle("Создать", for: .normal)
        button.addTarget(self, action: #selector(didCreateTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        view.backgroundColor = .Theme.background
        tableView.configure(provider: tableProvider, cell: SettingsCell.self)
        tableView.delegate = self
        updateCreateButtonState()
        setupConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutIfNeeded()
        emojiCollection.layoutIfNeeded()
        colorsCollection.layoutIfNeeded()
        emojiCollectionHeightConstraint.constant = emojiCollection.contentSize.height
        colorsCollectionHeightConstraint.constant = colorsCollection.contentSize.height
        tableHeightConstraint.constant = tableView.contentSize.height
    }

    func initialize(isIrregular: Bool, trackerInfo: TrackerInfo? = nil) {
        tableProvider.setIsIrregular(isIrregular)
        setupInitialInfo(trackerInfo)
        updateData()
        setupNavBar()
    }

    private func setupInitialInfo(_ trackerInfo: TrackerInfo? = nil) {
        initialTrackerInfo = trackerInfo

        let recordsCount = trackerInfo?.recordsCount ?? 0
        let localizedCount = NSLocalizedString("countDays", comment: "")
        counterLabel.text = String(format: localizedCount, recordsCount)
        counterLabel.isHidden = trackerInfo == nil

        selectedDays = trackerInfo?.selectedDays ?? []
        selectedCategory = trackerInfo?.category.title
        nameInput.textField?.text = trackerInfo?.tracker.title
        emojiCollection.selectedEmoji = trackerInfo?.tracker.emoji
        colorsCollection.selectedColor = trackerInfo?.tracker.color
    }

    private func setupNavBar() {
        if initialTrackerInfo != nil {
            navigationItem.title = "Редактирование привычки"
        } else if tableProvider.isIrregular {
            navigationItem.title = "Новое нерегулярное событие"
        } else {
            navigationItem.title = "Новая привычка"
        }
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
    }

    @objc
    private func didCancelTapped() {
        dismiss(animated: true)
    }

    @objc
    private func didCreateTapped() {
        guard let selectedCategory,
              let selectedColor = colorsCollection.selectedColor,
              let selectedEmoji = emojiCollection.selectedEmoji,
              let trackerName = nameInput.textField?.text
        else { return }

        let tracker = Tracker(
            title: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            pinned: initialTrackerInfo?.tracker.pinned ?? false
        )

        let category = Category(title: selectedCategory)
        let trackerInfo = TrackerInfo(
            id: initialTrackerInfo?.id,
            tracker: tracker,
            selectedDays: selectedDays,
            category: category
        )
        didComplete?(self, trackerInfo)
    }

    private func updateCreateButtonState() {
        createButton.isDisabled = hasEmpty
    }

    private func updateTable() {
        updateData()
        tableView.reloadData()
        updateCreateButtonState()
    }

    private func updateData() {
        let scheduleSubtitle = selectedDays.count == Weekday.allCases.count
            ? "Каждый день"
            : selectedDays.map { $0.shortTranslated }.joined(separator: ", ")
        tableProvider.updateData(
            selectedCategory: selectedCategory,
            selectedSchedule: scheduleSubtitle
        )
    }

    private func setupConstraints() {
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        emojiCollectionHeightConstraint = emojiCollection.heightAnchor.constraint(equalToConstant: 0)
        colorsCollectionHeightConstraint = colorsCollection.heightAnchor.constraint(equalToConstant: 0)

        tableHeightConstraint.isActive = true
        emojiCollectionHeightConstraint.isActive = true
        colorsCollectionHeightConstraint.isActive = true

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        [
            counterLabel,
            nameInput,
            tableView,
            emojiCollection,
            colorsCollection,
            buttonsStack,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        if initialTrackerInfo != nil {
            counterLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24).isActive = true
            nameInput.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 40).isActive = true
        } else {
            nameInput.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24).isActive = true
        }

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            counterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: nameInput.bottomAnchor, constant: -19),

            emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -19),
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),

            colorsCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor),
            colorsCollection.leadingAnchor.constraint(equalTo: emojiCollection.leadingAnchor),
            colorsCollection.trailingAnchor.constraint(equalTo: emojiCollection.trailingAnchor),

            buttonsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsStack.topAnchor.constraint(equalTo: colorsCollection.bottomAnchor, constant: 40),
            buttonsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

// MARK: - UITableViewDelegate

extension EventSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let config = tableProvider.cellConfigs[indexPath.item]
        let viewController = config.destination.init()

        if let scheduleVC = viewController as? ScheduleViewController {
            scheduleVC.delegate = self
            scheduleVC.setSelectedDays(selectedDays)
        } else if let categoryVC = viewController as? CategoryViewController {
            let viewModel = CategoryViewModel()
            viewModel.selectCategory(selectedCategory)
            categoryVC.initialize(viewModel: viewModel)
            categoryVC.delegate = self
        }

        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
}

// MARK: - ScheduleViewControllerDelegate

extension EventSettingsViewController: ScheduleViewControllerDelegate {
    func didComplete(with schedule: [Weekday]) {
        selectedDays = schedule
        updateTable()
    }
}

// MARK: - CategoryViewControllerDelegate

extension EventSettingsViewController: CategoryViewControllerDelegate {
    func didComplete(with category: String?) {
        selectedCategory = category
        updateTable()
    }
}

// MARK: - ValidationTextFieldWrapperDelegate

extension EventSettingsViewController: ValidationTextFieldWrapperDelegate {
    func textFieldShouldReturn(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func onError(_ hasError: Bool) {
        updateCreateButtonState()
    }
}

// MARK: - EmojiCollectionDelegate

extension EventSettingsViewController: EmojiCollectionDelegate {
    func emojiCollection(_ collection: EmojiCollection, didSelectEmoji emoji: String?) {
        updateCreateButtonState()
    }
}

// MARK: - ColorsCollectionDelegate

extension EventSettingsViewController: ColorsCollectionDelegate {
    func colorsCollection(_ collection: ColorsCollection, didSelectColor color: UIColor?) {
        updateCreateButtonState()
    }
}
