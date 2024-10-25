import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - Life cycle

    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var pagesViewControllers = [UIViewController]()
    
    private var currentPage: OnboardingPageViewController.Page = .name
    private var trackButtonTapsCount = 0

    private lazy var first = OnboardingPageViewController(page: .name)
    private lazy var second = OnboardingPageViewController(page: .photo)
    private lazy var third = OnboardingPageViewController(page: .genres)
    
    private let continueButton = OnboardingButton()
    weak var delegate: OnboardingPageViewControllerDelegate?
    
    private var enteredName: String?
    private var selectedGenres: [Int] = []

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        first.delegate = self
        second.delegate = self
        third.delegate = self
        
        pagesViewControllers += [first, second, third]

        drawSelf()
        didUpdateTextFieldState(isFilled: false, text: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func drawSelf() {
        view.backgroundColor = .white

        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)

        addChildController(pageViewController, inside: view)
        if let pageFirst = pagesViewControllers.first {
            pageViewController.setViewControllers([pageFirst], direction: .forward, animated: false)
        }
        pageViewController.dataSource = self

        for subview in pageViewController.view.subviews {
            if let subview = subview as? UIScrollView {
                subview.isScrollEnabled = false
                break
            }
        }

        view.addSubviews(continueButton)

        continueButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview().inset(35)
            make.height.equalTo(50)
        }
    }
}

// MARK: - OnboardingPageViewControllerDelegate
extension OnboardingViewController {
    @objc private func didTapContinueButton() {
        switch currentPage {
        case .name:
            ProfileDataManager.shared.saveName(enteredName ?? "")
            pageViewController.setViewControllers([second], direction: .forward, animated: true)
            currentPage = .photo
        case .photo:
            pageViewController.setViewControllers([third], direction: .forward, animated: true)
            currentPage = .genres
        case .genres:
            ProfileDataManager.shared.saveSelectedGenres(selectedGenres)
            
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")

            let tabBarController = TabBarController.shared
            let navigationController = UINavigationController(rootViewController: tabBarController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pagesViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        return pagesViewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pagesViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        return pagesViewControllers[index + 1]
    }
}

extension UIViewController {
    func addChildController(_ childViewController: UIViewController, inside containerView: UIView?) {
        childViewController.willMove(toParent: self)
        containerView?.addSubview(childViewController.view)

        addChild(childViewController)

        childViewController.didMove(toParent: self)
    }
}

extension OnboardingViewController: OnboardingPageViewControllerDelegate {
    func didUpdateTextFieldState(isFilled: Bool, text: String?) {
        continueButton.isEnabled = isFilled
        continueButton.alpha = isFilled ? 1.0 : 0.5
        
        enteredName = text
    }
    
    func didUpdateSelectedGenres(_ selectedGenres: [Int]) {
        self.selectedGenres = selectedGenres
    }
}
