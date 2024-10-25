import SnapKit
import UIKit

protocol StarRatingControlDelegate: AnyObject {
    func starRatingDidChange(rating: Int)
}

class StarRatingControl: UIControl {
    weak var delegate: StarRatingControlDelegate?

    private let starStackView = UIStackView()
    private var starButtons: [UIButton] = []

    private var rating = 0 {
        didSet {
            updateStarColors()
            delegate?.starRatingDidChange(rating: rating)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStars()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupStars()
    }

    private func setupView() {
        backgroundColor = .clear

        starStackView.do { make in
            make.axis = .horizontal
            make.distribution = .fillEqually
            make.spacing = 11
            make.isUserInteractionEnabled = true
        }

        addSubview(starStackView)

        starStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }

    private func setupStars() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 27)

        for i in 1...5 {
            let button = UIButton()
            let image = UIImage(systemName: "star.fill", withConfiguration: configuration)
            button.setImage(image, for: .normal)
            button.tintColor = UIColor.white.withAlphaComponent(0.4)
            button.tag = i
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starStackView.addArrangedSubview(button)
            starButtons.append(button)
        }
    }

    private func updateStarColors() {
        for (index, button) in starButtons.enumerated() {
            button.tintColor = index < rating ? UIColor(hex: "#FFC41F") : UIColor.white.withAlphaComponent(0.4)
        }
    }

    @objc private func starTapped(_ sender: UIButton) {
        rating = sender.tag
    }

    func setRating(_ newRating: Int) {
        rating = min(max(newRating, 0), starButtons.count)
    }

    func updateStarSize(to pointSize: CGFloat) {
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize)
        for button in starButtons {
            let image = UIImage(systemName: "star.fill", withConfiguration: configuration)
            button.setImage(image, for: .normal)
        }
    }

    func updateStarSpacing(to spacing: CGFloat) {
        starStackView.spacing = spacing
    }
}
