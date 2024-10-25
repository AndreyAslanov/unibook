import SnapKit
import UIKit

final class LaunchScreenViewController: UIViewController {
    private let loadingLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var stackView = UIStackView()
    private let backgroundImageView = UIImageView()
    private let mainImageView = UIImageView()
    private let loadingIndicatorView = UIView()
    private let maskLayer = CALayer()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = R.image.launch_background()
        mainImageView.isHidden = false
        mainImageView.image = R.image.launch_main_image()

        loadingLabel.do { make in
            make.textColor = .white
            make.textAlignment = .center
            make.font = UIFont.systemFont(ofSize: 17)
        }

        activityIndicator.do { make in
            make.hidesWhenStopped = true
            make.color = .white
        }

        stackView.do { make in
            make.axis = .horizontal
            make.spacing = 4
            make.alignment = .center
            make.translatesAutoresizingMaskIntoConstraints = false
        }
        
        loadingIndicatorView.do { make in
            make.backgroundColor = .clear
            make.layer.cornerRadius = 5
            make.masksToBounds = true
        }

        maskLayer.do { make in
            make.backgroundColor = UIColor.white.cgColor
            make.cornerRadius = 5
            make.masksToBounds = true
        }

        stackView.addArrangedSubviews([activityIndicator, loadingLabel])
        view.addSubviews(backgroundImageView, stackView, mainImageView, loadingIndicatorView)
        loadingIndicatorView.layer.addSublayer(maskLayer)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainImageView.snp.makeConstraints { make in
            if UIDevice.isIphoneBelowX {
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(50)
            } else {
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(147)
            }
        }

        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(loadingIndicatorView.snp.top).offset(-10)
            make.height.equalTo(30)
        }

        activityIndicator.snp.makeConstraints { make in
            make.width.equalTo(22)
            make.height.equalTo(22)
        }
        
        loadingIndicatorView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-14)
            make.height.equalTo(10)

            if UIDevice.isIpad {
                make.leading.trailing.equalToSuperview().inset(192.75)
            } else {
                make.leading.trailing.equalToSuperview().inset(92.75)
            }
        }

        activityIndicator.startAnimating()

        var currentPercentage = 0
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            currentPercentage += 1
            self.loadingLabel.text = "\(currentPercentage)%"
            self.updateMaskLayerWidth(percentage: CGFloat(currentPercentage))
            if currentPercentage >= 100 {
                timer.invalidate()
            }
        }
    }
    
    private func updateMaskLayerWidth(percentage: CGFloat) {
        let width = loadingIndicatorView.frame.width * (percentage / 100)
        maskLayer.frame = CGRect(x: 0, y: 0, width: width, height: loadingIndicatorView.frame.height)
    }
}
