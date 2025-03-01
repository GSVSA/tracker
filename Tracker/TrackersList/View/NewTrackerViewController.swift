import UIKit

final class NewTrackerViewController: UIViewController {
    var didAddTracker: ((TrackerInfo) -> Void)?

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

    private func navigateToSettings(isIrregular: Bool) {
        let view = EventSettingsViewController()
        view.initialize(isIrregular: isIrregular)
        view.didComplete = { [weak self] vc, trackerInfo in
            self?.didComplete(vc, trackerInfo: trackerInfo)
        }
        let navController = UINavigationController(rootViewController: view)
        self.present(navController, animated: true)
    }

    @objc
    private func didAddHabitTapped() {
        navigateToSettings(isIrregular: false)
    }

    @objc
    private func didAddIrregularEventTapped() {
        navigateToSettings(isIrregular: true)
    }

    private func didComplete(_ vc: EventSettingsViewController, trackerInfo: TrackerInfo) {
        didAddTracker?(trackerInfo)
        vc.dismiss(animated: true)
        dismiss(animated: true)
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
