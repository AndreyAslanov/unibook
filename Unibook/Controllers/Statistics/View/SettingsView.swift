import SnapKit
import UIKit

protocol SettingsViewDelegate: AnyObject {
    func didTapView(type: SettingsView.SelfType)
}

final class SettingsView: UIControl {
    enum SelfType {
        case shareApp
        case usagePolicy
        case rateApp

        var title: String {
            switch self {
            case .shareApp: return L.shareApp()
            case .usagePolicy: return L.usagePolicy()
            case .rateApp: return L.rateApp()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .shareApp: return R.image.profile_share_icon()
            case .usagePolicy: return R.image.profile_policy_icon()
            case .rateApp: return R.image.profile_rate_icon()
            }
        }
    }

    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let imageView = UIImageView()
    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    private let type: SelfType
    weak var delegate: SettingsViewDelegate?

    init(type: SelfType) {
        self.type = type
        super.init(frame: .zero)
        setupView()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white.withAlphaComponent(0.08)
        layer.cornerRadius = 8
        imageView.image = type.image
        imageView.contentMode = .scaleAspectFit
        arrowImageView.image = R.image.profile_arrow()
        
        titleLabel.do { make in
            make.textColor = .white
            make.font = .systemFont(ofSize: 16, weight: .semibold)
            make.text = type.title
        }

        addSubviews(imageView, titleLabel, arrowImageView)

        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(26.5)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(15)
            make.centerY.equalToSuperview()
        }

        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(26)
            make.height.equalTo(22)
            make.width.equalTo(12)
        }
    }

    private func configureAppearance() {
        alpha = isHighlighted ? 0.5 : 1
    }

    @objc private func didTapView() {
        delegate?.didTapView(type: type)
    }
}
