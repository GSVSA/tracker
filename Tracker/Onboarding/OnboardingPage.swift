import UIKit

final class OnboardingPage: UIViewController {
    private(set) var pageIndex: Int?

    private let images = [
        UIImage(named: "Onboarding_1"),
        UIImage(named: "Onboarding_2"),
    ]

    private let titles: [String] = [
        "Отслеживайте только то, что хотите",
        "Даже если это  не литры воды и йога",
    ]

    private lazy var imageView = UIImageView()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = getCurrentTheme() == .light
            ? .Theme.contrast
            : .Theme.background
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }

    func setPageIndex(_ index: Int) {
        imageView.image = images[index]
        label.text = titles[index]
    }

    private func setupConstraints() {
        [
            imageView,
            label,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),

            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
