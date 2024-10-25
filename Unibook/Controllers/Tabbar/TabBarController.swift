import UIKit

final class TabBarController: UITabBarController {
    static let shared = TabBarController()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        let booksVC = UINavigationController(
            rootViewController: BookViewController()
        )
        let statisticsVC = UINavigationController(
            rootViewController: StatisticsViewController()
        )
        let favouriteVC = UINavigationController(
            rootViewController: FavouriteViewController()
        )
        let profileVC = UINavigationController(
            rootViewController: ProfileViewController()
        )

        booksVC.tabBarItem = UITabBarItem(
            title: L.books(),
            image: UIImage(systemName: "books.vertical.fill"),
            tag: 0
        )

        statisticsVC.tabBarItem = UITabBarItem(
            title: L.statistics(),
            image: UIImage(systemName: "doc.text.fill"),
            tag: 1
        )

        favouriteVC.tabBarItem = UITabBarItem(
            title: L.favourites(),
            image: UIImage(systemName: "heart.fill"),
            tag: 2
        )
        
        profileVC.tabBarItem = UITabBarItem(
            title: L.profile(),
            image: UIImage(systemName: "person.fill"),
            tag: 3
        )

        let viewControllers = [booksVC, statisticsVC, favouriteVC, profileVC]
        self.viewControllers = viewControllers

        updateTabBar()
    }
    
    func updateTabBar() {
        tabBar.backgroundColor = .white.withAlphaComponent(0.4)
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .white.withAlphaComponent(0.4)
        tabBar.itemPositioning = .automatic
    }
}
