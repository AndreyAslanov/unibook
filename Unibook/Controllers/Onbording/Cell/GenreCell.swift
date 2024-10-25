import UIKit

// MARK: - GenreCell
protocol GenreCellDelegate: AnyObject {
    func didTapGenreCell(at index: Int, isSelected: Bool)
}

final class GenreCell: UICollectionViewCell {
    static let reuseIdentifier = "GenreCell"
    
    private let imageView = UIImageView()
    weak var delegate: GenreCellDelegate?
    private let selectedImageView = UIImageView()
    private var index: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubviews(imageView, selectedImageView)
        setupImageView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        selectedImageView.image = R.image.selected_icon()
        selectedImageView.isHidden = true
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectedImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
            make.size.equalTo(26)
        }
    }

    func configure(with genre: GenreModel) {
        imageView.image = genre.image
        index = genre.index 
        selectedImageView.isHidden = !genre.isSelected
    }
    
    @objc private func didTapCell() {
        guard let index = index else { return }
        let isSelected = !selectedImageView.isHidden
        delegate?.didTapGenreCell(at: index, isSelected: !isSelected)
        selectedImageView.isHidden = isSelected
    }
}
