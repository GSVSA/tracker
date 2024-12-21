import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabItems()
    }
    
    private func setupTabItems() {
        let trackersListViewController = TrackersListViewContriller()
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

