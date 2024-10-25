import SnapKit
import UIKit

protocol BookSelectionDelegate: AnyObject {
    func didSelectType(at index: Int)
}

final class BookSelectionView: UIControl {
    private let mainContainerView = UIView()

    private let permanentContainerView = UIView()
    private let temporaryContainerView = UIView()

    private let permanentLabel = UILabel()
    private let temporaryLabel = UILabel()

    private let containerStackView = UIStackView()

    private var selectedIndex: Int = 0 {
        didSet {
            updateViewsAppearance()
        }
    }

    private var views: [UIView] = []
    weak var delegate: BookSelectionDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        mainContainerView.do { make in
            make.backgroundColor = .white.withAlphaComponent(0.2)
            make.layer.cornerRadius = 9
        }

        [permanentContainerView, temporaryContainerView].forEach { view in
            view.do { make in
                make.backgroundColor = .white
                make.layer.cornerRadius = 7
                make.clipsToBounds = true
            }
        }

        containerStackView.do { make in
            make.axis = .horizontal
            make.spacing = 0
            make.distribution = .fillEqually
        }

        permanentLabel.text = L.reading()
        temporaryLabel.text = L.read()
        permanentLabel.textAlignment = .center
        temporaryLabel.textAlignment = .center

        permanentContainerView.addSubview(permanentLabel)
        temporaryContainerView.addSubview(temporaryLabel)

        containerStackView.addArrangedSubviews(
            [permanentContainerView, temporaryContainerView]
        )
        mainContainerView.addSubviews(containerStackView)
        addSubview(mainContainerView)

        let tapGestureRecognizers = [
            UITapGestureRecognizer(target: self, action: #selector(permanentTapped)),
            UITapGestureRecognizer(target: self, action: #selector(temporaryTapped))
        ]

        permanentContainerView.addGestureRecognizer(tapGestureRecognizers[0])
        temporaryContainerView.addGestureRecognizer(tapGestureRecognizers[1])

        views = [permanentContainerView, temporaryContainerView]
        updateViewsAppearance()
    }

    private func setupConstraints() {
        mainContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        [permanentLabel, temporaryLabel].forEach { label in
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }

        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }

        [permanentContainerView, temporaryContainerView].forEach { view in
            view.snp.makeConstraints { make in
                make.width.equalToSuperview().dividedBy(2)
                make.top.bottom.equalToSuperview()
            }
        }
    }

    @objc private func permanentTapped() {
        selectedIndex = 0
    }

    @objc private func temporaryTapped() {
        selectedIndex = 1
    }

    private func updateViewsAppearance() {
        for (index, view) in views.enumerated() {
            if index == selectedIndex {
                view.backgroundColor = .white
                (view.subviews.first as? UILabel)?.textColor = .black
                (view.subviews.first as? UILabel)?.font = .systemFont(ofSize: 16, weight: .semibold)
            } else {
                view.backgroundColor = .clear
                (view.subviews.first as? UILabel)?.textColor = .white
                (view.subviews.first as? UILabel)?.font = .systemFont(ofSize: 16, weight: .semibold)
            }
        }
        delegate?.didSelectType(at: selectedIndex)
    }

    func configure(selectedIndex: Int) {
        guard selectedIndex >= 0 && selectedIndex < views.count else {
            fatalError("Invalid index provided for PersonnelSelectionView configuration")
        }
        self.selectedIndex = selectedIndex
    }
}
