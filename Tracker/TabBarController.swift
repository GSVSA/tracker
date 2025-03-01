import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundColor = .Theme.background
        setupTabItems()
        setupTabBarBorder()
    }

    private func setupTabBarBorder() {
        let borderColor = UIColor.Theme.secondary.cgColor
        let borderWidth: CGFloat = 0.5

        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: borderWidth)
        borderLayer.backgroundColor = borderColor

        tabBar.layer.addSublayer(borderLayer)
        tabBar.layer.masksToBounds = true
    }

    private func setupTabItems() {
        let trackersViewModel = TrackersViewModel()
        let trackersViewController = TrackersListViewController()
        trackersViewController.initialize(viewModel: trackersViewModel)
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackersTitle", comment: "Название вкладки в навигации"),
            image: UIImage(named: "TrackersTabIcon"),
            selectedImage: nil
        )
        
        let statisticViewController = StatisticViewController()
        let statisticViewModel = StatisticsViewModel()
        statisticViewController.initialize(viewModel: statisticViewModel)
        let statisticNavigationController = UINavigationController(rootViewController: statisticViewController)
        statisticNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statisticsTitle", comment: "Название вкладки в навигации"),
            image: UIImage(named: "StatisticTabIcon"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersNavigationController, statisticNavigationController]
    }
    
}

