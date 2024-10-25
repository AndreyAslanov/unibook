import SafariServices
import StoreKit
import UIKit
import WebKit

final class AppActions {
    static let shared = AppActions()

    // MARK: - Private Initializer
    private init() {}

    // MARK: - Public Methods
    func shareApp() {
        guard let currentViewController = getCurrentViewController() else { return }
        shareAppInternal(from: currentViewController)
    }

    func rateApp() {
        guard let currentViewController = getCurrentViewController() else { return }
        rateAppInternal(from: currentViewController)
    }

    func showUsagePolicy() {
        guard let currentViewController = getCurrentViewController() else { return }
        openWebPage(url: AppLinks.usagePolicyURL, from: currentViewController)
    }

    // MARK: - Private Methods
    private func shareAppInternal(from viewController: UIViewController, sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
        let itemsToShare = [AppLinks.appShareURL]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)

        // For iPad
        if let popoverController = activityViewController.popoverPresentationController {
            if let barButtonItem = barButtonItem {
                popoverController.barButtonItem = barButtonItem
            } else if let sourceView = sourceView {
                popoverController.sourceView = sourceView
                popoverController.sourceRect = sourceView.bounds
            } else {
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }

        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact]
        viewController.present(activityViewController, animated: true, completion: nil)
    }

    private func rateAppInternal(from viewController: UIViewController) {
        if #available(iOS 14.0, *) {
            if let scene = viewController.view.window?.windowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            if UIApplication.shared.canOpenURL(AppLinks.appStoreReviewURL) {
                UIApplication.shared.open(AppLinks.appStoreReviewURL, options: [:], completionHandler: nil)
            }
        }
    }

    private func openWebPage(url: URL, from viewController: UIViewController) {
        let webView = WKWebView()
        webView.navigationDelegate = viewController as? WKNavigationDelegate
        webView.load(URLRequest(url: url))

        let webViewViewController = UIViewController()
        webViewViewController.view = webView

        viewController.present(webViewViewController, animated: true, completion: nil)
    }

    private func getCurrentViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }

        var viewController = rootViewController
        while let presentedViewController = viewController.presentedViewController {
            viewController = presentedViewController
        }

        return viewController
    }
}
