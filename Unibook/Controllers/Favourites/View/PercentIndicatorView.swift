import UIKit

class PercentIndicatorView: UIView {
    private let backgroundLayer = CALayer()
    private let fillLayer = CALayer()

    var percentage: Int = 0 {
        didSet {
            updateFillLayer()
        }
    }

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup View
    private func setupView() {
        backgroundLayer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backgroundLayer.cornerRadius = 3.5
        layer.addSublayer(backgroundLayer)

        fillLayer.backgroundColor = UIColor.white.cgColor
        fillLayer.cornerRadius = 3.5
        layer.addSublayer(fillLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = bounds
        updateFillLayer()
    }

    // MARK: - Update Fill Layer
    private func updateFillLayer() {
        let fillWidth = bounds.width * CGFloat(percentage) / 100
        fillLayer.frame = CGRect(x: 0, y: 0, width: fillWidth, height: bounds.height)
    }

    func setPercentage(_ value: Int) {
        percentage = max(0, min(100, value))
        updateFillLayer()
    }
}
