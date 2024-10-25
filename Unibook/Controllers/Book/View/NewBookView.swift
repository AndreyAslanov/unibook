import SnapKit
import UIKit

protocol NewBookViewDelegate: AnyObject {
    func didTapButton()
}

final class NewBookView: UIControl {
    weak var delegate: NewBookViewDelegate?

    private let title = UILabel()
    private let subtitle = UILabel()
    private let buttonView = UIView()
    private let plusImageView = UIImageView()
    private let addLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
        setupConstraints()
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func drawSelf() {
        backgroundColor = .white.withAlphaComponent(0.2)
        layer.cornerRadius = 20

        title.do { make in
            make.text = L.addBook()
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.textColor = .white
            make.textAlignment = .center
            make.isUserInteractionEnabled = false
        }

        subtitle.do { make in
            make.text = L.downloadBook()
            make.font = .systemFont(ofSize: 16)
            make.textColor = .white.withAlphaComponent(0.7)
            make.textAlignment = .center
            make.isUserInteractionEnabled = false
        }

        buttonView.do { make in
            make.backgroundColor = .white
            make.layer.cornerRadius = 12
            make.clipsToBounds = true
        }

        plusImageView.do { make in
            make.image = UIImage(systemName: "plus.square.fill")
            make.tintColor = .black
            make.contentMode = .scaleAspectFit
        }

        addLabel.do { make in
            make.text = L.addBook()
            make.textColor = .black
            make.font = UIFont.systemFont(ofSize: 17)
        }

        stackView.do { make in
            make.axis = .horizontal
            make.spacing = 4
            make.alignment = .center
        }

        stackView.addArrangedSubviews([plusImageView, addLabel])
        buttonView.addSubviews(stackView)
        addSubviews(title, subtitle, buttonView)
    }

    private func setupConstraints() {
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26.5)
            make.centerX.equalToSuperview()
        }

        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        buttonView.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(151)
        }

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(plusViewTapped))
        buttonView.addGestureRecognizer(tapGesture)
    }

    @objc private func plusViewTapped() {
        delegate?.didTapButton()
    }

    func updateTitle(with newText: String) {
        title.text = newText
    }
}
