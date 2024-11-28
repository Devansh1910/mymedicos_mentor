import UIKit
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class MainTabBarViewController: UITabBarController {
    
    var phoneNumber: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.navigationItem.hidesBackButton = true
        
        let savedPhoneNumber = UserDefaults.standard.string(forKey: "savedPhoneNumber")

        if let number = savedPhoneNumber {
            phoneNumber = number
            print("App launched. Retrieved saved phone number: \(number)")
            passPhoneNumberToHomeVC(phoneNumber: number)
        } else {
            print("App launched. No saved phone number found.")
        }
        
        setupTabBarControllers()
        configureTabBarAppearance()
    }

    private func passPhoneNumberToHomeVC(phoneNumber: String) {
        if let viewControllers = self.viewControllers {
            for viewController in viewControllers {
                if let homeVC = viewController as? HomeViewController {
                    // Pass phone number to HomeViewController
                } else if let navController = viewController as? UINavigationController {
                    if let homeVC = navController.viewControllers.first as? HomeViewController {
                        // Pass phone number to HomeViewController
                    }
                }
            }
        }
    }

    func setupTabBarControllers() {
        // Initialize view controllers
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        
        // Embed AskaDoubtPGView in a hosting controller
        let doubtsVC = UIHostingController(rootView: AskaDoubtPGView())
        doubtsVC.tabBarItem = UITabBarItem(
            title: "Ask a Doubt",
            image: UIImage(systemName: "questionmark.bubble.fill"),
            tag: 1
        )
        
        let vc3 = UINavigationController(rootViewController: ProfileViewController())

        
        // Set titles
        vc1.title = "Home"
        vc3.title = "Profile"
        
        // Set icons for standard tabs
        vc1.tabBarItem.image = UIImage(systemName: "chart.pie.fill")
        vc3.tabBarItem.image = UIImage(systemName: "person")

        
        setViewControllers([vc1, doubtsVC, vc3], animated: true)
        tabBar.tintColor = .label
    }

    private func configureTabBarAppearance() {
        tabBar.barTintColor = .white // Set the tab bar background color to white
        tabBar.isTranslucent = false // Make the tab bar non-translucent
        tabBar.backgroundColor = .white // Ensure the background color is white
    }
}
