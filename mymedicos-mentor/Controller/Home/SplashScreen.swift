import UIKit
import Lottie

class SplashScreenViewController: UIViewController {

    private let animationView = LottieAnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        animationView.animation = LottieAnimation.named("logoanim")
        animationView.frame = view.bounds
        animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play()

        view.addSubview(animationView)
    }

    func moveToMainAppScreen() {
        let mainTabBarVC = MainTabBarViewController()
        mainTabBarVC.modalTransitionStyle = .crossDissolve
        mainTabBarVC.modalPresentationStyle = .fullScreen
        present(mainTabBarVC, animated: true, completion: nil)
    }
}
