import SnapKit
import UIKit

protocol FavCellDelegate: AnyObject {
    func didTapEditButton(with book: FavouriteModel)
    func didTapDeleteButton(with book: FavouriteModel)
}

class FavCell: UICollectionViewCell {
    static let reuseIdentifier = "FavCell"
    weak var delegate: FavCellDelegate?
    var bookModel: FavouriteModel?
    
    private let bookImageView = UIImageView()
    private let bookTitleLabel = UILabel()
    private let authorLabel = UILabel()
    private let starRatingControl = StarRatingControl()
    private let percentIndicator: PercentIndicatorView
    private let percentLabel = UILabel()
    private let feedbackLabel = UILabel()
    
    private let deleteButton = UIButton()
    private let editButton = UIButton()

    override init(frame: CGRect) {
        if UIDevice.isIphoneBelowX {
            percentIndicator = PercentIndicatorView(frame: CGRect(x: 0, y: 0, width: 170, height: 7))
        } else {
            percentIndicator = PercentIndicatorView(frame: CGRect(x: 0, y: 0, width: 210, height: 7))
        }
        
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white.withAlphaComponent(0.2)
        layer.cornerRadius = 8
        
        starRatingControl.updateStarSize(to: 14)
        starRatingControl.updateStarSpacing(to: 4)
        
        bookImageView.do { make in
            make.image = R.image.fav_image_placeholder()
            make.contentMode = .scaleAspectFill
            make.clipsToBounds = true
            make.isUserInteractionEnabled = true
            make.layer.cornerRadius = 8
        }
        
        bookTitleLabel.do { make in
            make.font = .systemFont(ofSize: 13, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .left
        }        
        
        authorLabel.do { make in
            make.font = .systemFont(ofSize: 12, weight: .medium)
            make.textColor = .white.withAlphaComponent(0.7)
            make.textAlignment = .left
        }        
        
        feedbackLabel.do { make in
            make.font = .systemFont(ofSize: 12, weight: .medium)
            make.textColor = .white.withAlphaComponent(0.7)
            make.numberOfLines = 4
        }        
        
        percentLabel.do { make in
            make.font = .systemFont(ofSize: 12)
            make.textColor = .white
            make.textAlignment = .right
        }
        
        deleteButton.do { make in
            make.setImage(UIImage(systemName: "trash"), for: .normal)
            make.tintColor = .white
            make.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        }        
        
        editButton.do { make in
            make.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            make.tintColor = .white
            make.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        }

        contentView.addSubviews(
            bookImageView, bookTitleLabel, authorLabel, starRatingControl,
            feedbackLabel, percentIndicator, percentLabel, deleteButton, editButton
        )
        
        bookImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(5.5)
            make.height.equalTo(117)
            make.width.equalTo(80)
        }
        
        bookTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(bookImageView.snp.trailing).offset(12)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(bookTitleLabel.snp.bottom)
            make.leading.equalTo(bookImageView.snp.trailing).offset(12)
        }
        
        starRatingControl.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(38)
            make.leading.equalTo(bookImageView.snp.trailing).offset(12)
            make.height.equalTo(14)
            make.width.equalTo(86)
        }
        
        percentIndicator.snp.makeConstraints { make in
            make.top.equalTo(starRatingControl.snp.bottom).offset(8.5)
            make.leading.equalTo(bookImageView.snp.trailing).offset(12)
            make.height.equalTo(7)
            if UIDevice.isIphoneBelowX {
                make.width.equalTo(170)
            } else {
                make.width.equalTo(210)
            }
        }
        
        percentLabel.snp.makeConstraints { make in
            make.centerY.equalTo(percentIndicator.snp.centerY)
            make.trailing.equalToSuperview().inset(18.5)
        }
        
        feedbackLabel.snp.makeConstraints { make in
            make.top.equalTo(bookImageView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().inset(9.5)
            make.size.equalTo(24)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalTo(deleteButton.snp.leading)
            make.size.equalTo(24)
        }
    }

    @objc private func didTapEditButton() {
        guard let bookModel = bookModel else { return }
        delegate?.didTapEditButton(with: bookModel)
    }
    
    @objc private func didTapDeleteButton() {
        guard let bookModel = bookModel else { return }
        delegate?.didTapDeleteButton(with: bookModel)
    }

    func configure(with book: FavouriteModel) {
        bookModel = book
        
        bookTitleLabel.text = book.bookTitle
        authorLabel.text = book.author
        percentLabel.text = String("\(book.proccess) %")
        percentIndicator.setPercentage(book.proccess)
        starRatingControl.setRating(book.rating)
        feedbackLabel.text = book.feedback
        
        if let imagePath = book.favImagePath, let uuid = UUID(uuidString: imagePath) {
            loadImage(for: uuid) { [weak self] image in
                DispatchQueue.main.async {
                    self?.bookImageView.image = image
                    if image == nil {
                        print("Failed to load image for UUID: \(imagePath)")
                    }
                }
            }
        }
    }
    
    private func loadImage(for id: UUID, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let image = FavouriteDataManager.shared.loadImage(withId: id)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
