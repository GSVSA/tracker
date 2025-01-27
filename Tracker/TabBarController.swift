import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = .Theme.accent
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
        let trackersListViewController = TrackersListViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersListViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "TrackersTabIcon"),
            selectedImage: nil
        )
        
        let statisticViewController = StatisticViewController()
        let statisticNavigationController = UINavigationController(rootViewController: statisticViewController)
        statisticNavigationController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "StatisticTabIcon"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersNavigationController, statisticNavigationController]
    }
    
}

