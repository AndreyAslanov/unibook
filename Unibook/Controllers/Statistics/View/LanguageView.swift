import SnapKit
import UIKit

protocol LanguageViewDelegate: AnyObject {
    func didTapLanguageButton()
}

final class LanguageView: UIControl {
    weak var delegate: LanguageViewDelegate?

    private let languageLabel = UILabel()
    private let valueLabel = UILabel()
    private let languageImageView = UIImageView()
    private let languageButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func drawSelf() {
        backgroundColor = .white.withAlphaComponent(0.08)
        layer.cornerRadius = 8

        languageImageView.image = R.image.statistics_language_icon()

        languageLabel.do { make in
            make.text = L.favLanguage()
            make.font = .systemFont(ofSize: 20, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .left
        }        
        
        valueLabel.do { make in
            make.text = L.noData()
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white.withAlphaComponent(0.7)
            make.textAlignment = .left
        }

        languageButton.do { make in
            let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
            let bookImage = UIImage(systemName: "square.and.pencil", withConfiguration: configuration)

            make.setImage(bookImage, for: .normal)
            make.addTarget(self, action: #selector(languageButtonTapped), for: .touchUpInside)
            make.tintColor = .white
        }

        addSubviews(languageImageView, languageLabel, valueLabel, languageButton)
    }

    private func setupConstraints() {
        languageImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }
        
        languageLabel.snp.makeConstraints { make in
            make.leading.equalTo(languageImageView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(languageImageView.snp.trailing).offset(12)
            make.bottom.equalToSuperview().inset(12)
        }

        languageButton.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(12)
            make.size.equalTo(32)
        }
    }

    @objc private func languageButtonTapped() {
        delegate?.didTapLanguageButton()
    }

    func configureValueLabel(with value: String) {
        valueLabel.text = value
    }
}
