import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didAddTracker(_ vc: NewTrackerViewController, tracker: TrackerProtocol, selectedDays: [Weekday], category: CategoryProtocol)
}

final class NewTrackerViewController: UIViewController {
    weak var delegate: NewTrackerViewControllerDelegate?

    private lazy var habitButton: Button = {
        let button = Button()
        button.setTitle("Привычка", for: .normal)
        button.addTarget(self, action: #selector(didAddHabitTapped), for: .touchUpInside)
        return button
    }()

    private lazy var irregularEventButton: Button = {
        let button = Button()
        button.setTitle("Нерегулярные событие", for: .normal)
        button.addTarget(self, action: #selector(didAddIrregularEventTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [habitButton, irregularEventButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .Theme.background
        navigationItem.title = "Создание трекера"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
        setupConstraints()
    }

    @objc
    private func didAddHabitTapped() {
        let view = EventSettingsViewController()
        view.setIsIrregular(false)
        view.delegate = self
        let navController = UINavigationController(rootViewController: view)
        self.present(navController, animated: true)
    }

    @objc
    private func didAddIrregularEventTapped() {
        let view = EventSettingsViewController()
        view.setIsIrregular(true)
        view.delegate = self
        let navController = UINavigationController(rootViewController: view)
        self.present(navController, animated: true)
    }

    private func setupConstraints() {
        [
            buttonsStack,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            buttonsStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            buttonsStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
}

// MARK: - EventSettingsViewControllerDelegate

extension NewTrackerViewController: EventSettingsViewControllerDelegate {
    func didComplete(_ vc: EventSettingsViewController, tracker: TrackerProtocol, selectedDays: [Weekday], category: CategoryProtocol) {
        delegate?.didAddTracker(self, tracker: tracker, selectedDays: selectedDays, category: category)
        vc.dismiss(animated: true)
        dismiss(animated: true)
    }
}
