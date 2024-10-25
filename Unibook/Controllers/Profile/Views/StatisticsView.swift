import SnapKit
import UIKit

protocol StatisticsViewDelegate: AnyObject {
    func didTapView(type: StatisticsView.StatisticsType)
}

final class StatisticsView: UIControl {
    enum StatisticsType {
        case reading
        case time
        case genre
        case author

        var title: String {
            switch self {
            case .reading: return L.statReading()
            case .time: return L.statTime()
            case .genre: return L.statGenre()
            case .author: return L.statAuthor()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .reading: return R.image.statistics_reading_icon()
            case .time: return R.image.statistics_time_icon()
            case .genre: return R.image.statistics_genre_icon()
            case .author: return R.image.statistics_author_icon()
            }
        }
    }

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let editButton = UIButton()
    private let imageView = UIImageView()

    private let type: StatisticsType
    weak var delegate: StatisticsViewDelegate?

    init(type: StatisticsType) {
        self.type = type
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white.withAlphaComponent(0.2)
        layer.cornerRadius = 20
        
        imageView.image = type.image
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.do { make in
            make.textColor = .white
            make.font = .systemFont(ofSize: 20, weight: .semibold)
            make.text = type.title
            make.numberOfLines = 0
        }        
        
        valueLabel.do { make in
            make.text = L.noData()
            make.textColor = .white.withAlphaComponent(0.4)
            make.font = .systemFont(ofSize: 17, weight: .semibold)
        }
        
        editButton.do { make in
            let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
            let bookImage = UIImage(systemName: "square.and.pencil", withConfiguration: configuration)

            make.setImage(bookImage, for: .normal)
            make.addTarget(self, action: #selector(bookButtonTapped), for: .touchUpInside)
            make.tintColor = .white
        }

        addSubviews(titleLabel, imageView, valueLabel, editButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.width.equalTo(110)
        }

        imageView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(12)
            make.size.equalTo(48)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(12)
        }
        
        editButton.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(12)
            make.size.equalTo(32)
        }
    }
    
    @objc private func bookButtonTapped() {
        delegate?.didTapView(type: type)
    }
    
    func configureValueLabel(with value: String) {
        valueLabel.text = value
    }
}
