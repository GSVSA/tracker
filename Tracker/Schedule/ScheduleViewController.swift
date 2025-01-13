import UIKit

struct ScheduleCellModel: SettingsTableItem {
    let title: String
    let subtitle: String?
    let isSelected: Bool?

    init(title: String, isSelected: Bool?) {
        self.title = title
        self.subtitle = nil
        self.isSelected = isSelected
    }
}

final class ScheduleViewController: UIViewController {
    var delegate: ScheduleViewControllerDelegate?

    private var selectedDays: [Weekday: Bool] = [:]

    private var tableHeightConstraint: NSLayoutConstraint!

    private lazy var tableView = SettingsTable()

    private lazy var doneButton: Button = {
        let button = Button()
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(didDoneTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .Theme.background
        configureNavBar()

        let tableItems = Weekday.allCases.map { day in
            ScheduleCellModel(title: day.translated, isSelected: selectedDays[day])
        }
        tableView.setCellConfig(.init(isSwitcher: true))
        tableView.configure(items: tableItems, cell: SettingsCell.self, reuseIdentifier: "scheduleSettingsCell")
        tableView.settingsCellDelegate = self

        setupConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeightConstraint.constant = tableView.contentSize.height
    }

    func setSelectedDays(_ days: [Weekday]) {
        selectedDays = days.reduce(into: [:]) { result, day in
            result[day] = true
        }
    }

    @objc
    private func didDoneTapped() {
        let selectedDays = selectedDays
            .filter { $0.value }
            .map { $0.key }
            .sorted {
                guard let firstIndex = Weekday.allCases.firstIndex(of: $0),
                      let secondIndex = Weekday.allCases.firstIndex(of: $1)
                else { return false }
                return firstIndex < secondIndex
            }
        delegate?.didComplete(with: selectedDays)
        dismiss(animated: true)
    }

    private func configureNavBar() {
        navigationItem.title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
    }

    private func setupConstraints() {
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint.isActive = true
        [
            tableView,
            doneButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -11),

            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
}

extension ScheduleViewController: SettingsCellDelegate {
    func didChangeValue(_ sender: UISwitch, for indexPath: IndexPath, isOn: Bool) {
        selectedDays.updateValue(isOn, forKey: Weekday.allCases[indexPath.row])
    }
}
