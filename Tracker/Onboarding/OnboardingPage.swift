import UIKit

protocol PageProtocol {
    var image: UIImage? { get }
    var title: String { get }
}

final class OnboardingPage: UIViewController {
    private let page: PageProtocol

    private lazy var imageView = UIImageView(image: page.image)

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = ThemeManager.themed(light: .Theme.contrast, dark: .Theme.background)
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.text = page.title
        return label
    }()

    init(page: PageProtocol) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
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
