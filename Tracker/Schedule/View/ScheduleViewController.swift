import UIKit

final class ScheduleViewController: UIViewController {
    var delegate: ScheduleViewControllerDelegate?

    private var tableHeightConstraint: NSLayoutConstraint!

    private lazy var tableProvider = ScheduleTableProvider()

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

        tableView.configure(provider: tableProvider, cell: SettingsCell.self)
        tableView.settingsCellDelegate = self

        setupConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeightConstraint.constant = tableView.contentSize.height
    }

    func setSelectedDays(_ days: [Weekday]) {
        tableProvider.setSelectedDays(days)
    }

    @objc
    private func didDoneTapped() {
        let selectedDays = tableProvider.selectedDays
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

// MARK: - SettingsCellDelegate

extension ScheduleViewController: SettingsCellDelegate {
    func didChangeValue(_ sender: UISwitch, for indexPath: IndexPath, isOn: Bool) {
        tableProvider.updateValue(day: Weekday.allCases[indexPath.item], value: isOn)
    }
}
