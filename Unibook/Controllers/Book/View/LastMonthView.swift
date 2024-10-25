import SnapKit
import UIKit

protocol LastMonthViewDelegate: AnyObject {
    func didTapBookButton()
    func didTapPageButton()
}

final class LastMonthView: UIControl {
    weak var delegate: LastMonthViewDelegate?

    private let lastMonthLabel = UILabel()
    private let booksView = UIView()
    private let pagesView = UIView()

    private let bookImageView = UIImageView()
    private let pageImageView = UIImageView()

    private let numberBooksLabel = UILabel()
    private let numberPagesLabel = UILabel()

    private let bookValueLabel = UILabel()
    private let pageValueLabel = UILabel()

    private let bookButton = UIButton()
    private let pageButton = UIButton()

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
        layer.cornerRadius = 20

        bookImageView.image = R.image.books_books_icon()
        pageImageView.image = R.image.books_pages_icon()

        lastMonthLabel.do { make in
            make.text = L.lastMonth()
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .left
        }

        [booksView, pagesView].forEach { view in
            view.do { make in
                make.backgroundColor = .white.withAlphaComponent(0.08)
                make.layer.cornerRadius = 8
                make.isUserInteractionEnabled = true
            }
        }

        [numberBooksLabel, numberPagesLabel].forEach { label in
            label.do { make in
                make.font = .systemFont(ofSize: 12, weight: .medium)
                make.textColor = .white.withAlphaComponent(0.7)
                make.numberOfLines = 0
            }
        }

        [bookValueLabel, pageValueLabel].forEach { label in
            label.do { make in
                make.text = "0"
                make.font = .systemFont(ofSize: 17, weight: .semibold)
                make.textColor = .white.withAlphaComponent(0.7)
                make.numberOfLines = 0
            }
        }

        bookButton.do { make in
            let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
            let bookImage = UIImage(systemName: "square.and.pencil", withConfiguration: configuration)

            make.setImage(bookImage, for: .normal)
            make.addTarget(self, action: #selector(bookButtonTapped), for: .touchUpInside)
            make.tintColor = .white
        }

        pageButton.do { make in
            let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
            let pageImage = UIImage(systemName: "square.and.pencil", withConfiguration: configuration)

            make.setImage(pageImage, for: .normal)
            make.addTarget(self, action: #selector(pageButtonTapped), for: .touchUpInside)
            make.tintColor = .white
        }

        numberBooksLabel.text = L.numberBooks()
        numberPagesLabel.text = L.numberPages()

        booksView.addSubviews(bookImageView, numberBooksLabel, bookValueLabel, bookButton)
        pagesView.addSubviews(pageImageView, numberPagesLabel, pageValueLabel, pageButton)

        addSubviews(lastMonthLabel, booksView, pagesView)
    }

    private func setupConstraints() {
        lastMonthLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
        }

        booksView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(12)
            make.height.equalTo(132)
            make.width.equalToSuperview().dividedBy(2).offset(-16)
        }

        pagesView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(12)
            make.height.equalTo(132)
            make.width.equalToSuperview().dividedBy(2).offset(-16)
        }

        [bookImageView, pageImageView].forEach { imageView in
            imageView.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(12)
                make.size.equalTo(40)
            }
        }

        numberBooksLabel.snp.makeConstraints { make in
            make.top.equalTo(bookImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        numberPagesLabel.snp.makeConstraints { make in
            make.top.equalTo(pageImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        [bookValueLabel, pageValueLabel].forEach { label in
            label.snp.makeConstraints { make in
                make.bottom.leading.trailing.equalToSuperview().inset(12)
            }
        }

        bookButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(bookImageView.snp.centerY)
            make.size.equalTo(32)
        }

        pageButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(pageImageView.snp.centerY)
            make.size.equalTo(32)
        }
    }

    @objc private func bookButtonTapped() {
        delegate?.didTapBookButton()
    }

    @objc private func pageButtonTapped() {
        delegate?.didTapPageButton()
    }

    func configureBookValueLabel(with value: String) {
        bookValueLabel.text = value
    }

    func configurePageValueLabel(with value: String) {
        pageValueLabel.text = value
    }
}
