import UIKit

/**
 Keeps the navigation bar hidden in the onboarding controllers
 and visible in the others, with a light status bar
 */
extension UINavigationController {
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    public override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return self.topViewController
    }
}
