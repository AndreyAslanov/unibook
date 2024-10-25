import UIKit

protocol CustomSliderDelegate: AnyObject {
    func sliderValueDidChange(_ slider: CustomSlider, value: Int)
}

class CustomSlider: UIControl {
    private var thumbView: UIView!
    private var trackLayer: CALayer!
    private var minimumValue: CGFloat = 0
    private var maximumValue: CGFloat = 1
    private var currentValue: CGFloat = 0 {
        didSet {
            updateThumbPosition()
            updateTrackLayer()
        }
    }

    weak var delegate: CustomSliderDelegate?

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        trackLayer = CALayer()
        layer.addSublayer(trackLayer)

        thumbView = UIView()
        thumbView.backgroundColor = UIColor(hex: "#31602F")
        thumbView.layer.cornerRadius = 8
        thumbView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        addSubview(thumbView)

        thumbView.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        thumbView.addGestureRecognizer(panGesture)
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        let trackHeight: CGFloat = 4
        trackLayer.frame = CGRect(x: 0, y: (bounds.height - trackHeight) / 2, width: bounds.width, height: trackHeight)
        trackLayer.cornerRadius = trackHeight / 2
        updateThumbPosition()
        updateTrackLayer()
    }

    // MARK: - Handle Pan Gesture
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        let width = bounds.width

        let newValue = max(minimumValue, min(maximumValue, minimumValue + (location.x / width) * (maximumValue - minimumValue)))
        currentValue = newValue

        let scaledValue = Int((currentValue - minimumValue) / (maximumValue - minimumValue) * 100)
        delegate?.sliderValueDidChange(self, value: scaledValue)

        sendActions(for: .valueChanged)
    }

    // MARK: - Update Thumb Position
    private func updateThumbPosition() {
        let width = bounds.width
        let thumbX = (currentValue - minimumValue) / (maximumValue - minimumValue) * (width - thumbView.bounds.width)
        thumbView.center = CGPoint(x: thumbX + thumbView.bounds.width / 2, y: bounds.height / 2)
    }

    // MARK: - Update Track Layer
    private func updateTrackLayer() {
        let filledWidth = (currentValue - minimumValue) / (maximumValue - minimumValue) * bounds.width

        let filledTrackLayer = CALayer()
        filledTrackLayer.frame = CGRect(x: 0, y: 0, width: filledWidth, height: 4)
        filledTrackLayer.backgroundColor = UIColor(hex: "#31602F").cgColor
        filledTrackLayer.cornerRadius = 2

        trackLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        trackLayer.addSublayer(filledTrackLayer)

        let unfilledTrackLayer = CALayer()
        unfilledTrackLayer.frame = CGRect(x: filledWidth, y: 0, width: bounds.width - filledWidth, height: 4)
        unfilledTrackLayer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
        unfilledTrackLayer.cornerRadius = 2

        trackLayer.addSublayer(unfilledTrackLayer)
    }

    // MARK: - Public Methods
    func setMinimumValue(_ value: CGFloat) {
        minimumValue = value
        setValue(currentValue)
    }

    func setMaximumValue(_ value: CGFloat) {
        maximumValue = value
        setValue(currentValue)
    }

    func value() -> CGFloat {
        return currentValue
    }

    // MARK: - Public Methods
    func setSliderValue(value: Int, animated: Bool = false) {
        let scaledValue = CGFloat(value) / 100 * (maximumValue - minimumValue) + minimumValue
        setValue(scaledValue, animated: animated)
    }

    // MARK: - Private Methods
    private func setValue(_ value: CGFloat, animated: Bool = false) {
        let clampedValue = max(minimumValue, min(maximumValue, value))

        if animated {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.currentValue = clampedValue
                self?.layoutIfNeeded()
            }
        } else {
            currentValue = clampedValue
        }

        sendActions(for: .valueChanged)

        let scaledValue = Int((currentValue - minimumValue) / (maximumValue - minimumValue) * 100)
        delegate?.sliderValueDidChange(self, value: scaledValue)
    }
}
