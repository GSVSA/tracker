import UIKit

final class OnboardingViewController: UIPageViewController {
    private lazy var onboardingManager = OnboardingManager()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = getCurrentTheme() == .light
            ? .Theme.contrast
            : .Theme.background
        pageControl.pageIndicatorTintColor = getCurrentTheme() == .light
            ? .Theme.contrast.withAlphaComponent(0.3)
            : .Theme.background.withAlphaComponent(0.3)
        pageControl.addTarget(self, action: #selector(didPageControlTap), for: .valueChanged)
        return pageControl
    }()

    private lazy var pages: [UIViewController] = {
        let firstPage = OnboardingPage()
        firstPage.setPageIndex(0);

        let secondPage = OnboardingPage()
        secondPage.setPageIndex(1);

        return [firstPage, secondPage]
    }()

    private lazy var button: UIButton = {
        let button = Button()
        button.setTitle("Вот это технологии!", for: .normal)
        if getCurrentTheme() == .light {
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
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = TabBarController()
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
