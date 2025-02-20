import UIKit

struct PageModel: PageProtocol {
    let image: UIImage?
    let title: String
}

final class OnboardingViewController: UIPageViewController {
    var onFinish: (() -> Void)?

    private lazy var onboardingManager = OnboardingManager()

    private let pageModels: [PageModel] = [
        .init(image: UIImage(named: "Onboarding_1"), title: "Отслеживайте только то, что хотите"),
        .init(image: UIImage(named: "Onboarding_2"), title: "Даже если это  не литры воды и йога"),
    ]

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        let accentColor: UIColor = ThemeManager.isLightMode
            ? .Theme.contrast
            : .Theme.background
        pageControl.currentPageIndicatorTintColor = accentColor
        pageControl.pageIndicatorTintColor = accentColor.withAlphaComponent(0.3)

        pageControl.addTarget(self, action: #selector(didPageControlTap), for: .valueChanged)
        return pageControl
    }()

    private lazy var pages: [UIViewController] = {
        pageModels.map { OnboardingPage(page: $0) }
    }()

    private lazy var button: UIButton = {
        let button = Button()
        button.setTitle("Вот это технологии!", for: .normal)
        if ThemeManager.isLightMode {
            button.setTitleColor(.Theme.background, for: .normal)
            button.backgroundColor = .Theme.contrast
        } else {
            button.setTitleColor(.Theme.contrast, for: .normal)
            button.backgroundColor = .Theme.background
        }
        button.addTarget(self, action: #selector(didButtonTap), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        setupConstraints()
    }

    @objc
    private func didButtonTap() {
        onboardingManager.complete()
        onFinish?()
    }

    @objc
    private func didPageControlTap(_ sender: UIPageControl) {
        let viewController = pages[sender.currentPage]
        setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
    }

    private func setupConstraints() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -8),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // возвращаем предыдущий контроллер
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }

        return pages[previousIndex]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        // возвращаем следующий контроллер
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return nil
        }

        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
