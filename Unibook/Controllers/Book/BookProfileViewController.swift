import UIKit

final class BookProfileViewController: UIViewController {
    private let backgroundImageView = UIImageView()
    private let upperImageView = UIImageView()

    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    private let bookImageView = UIImageView()

    private let bookTitleLabel = UILabel()
    private let authorLabel = UILabel()
    private let aboutBookLabel = UILabel()
    private let aboutValueLabel = UILabel()
    private let customSlider = CustomSlider()
    private let starRatingControl = StarRatingControl()

    private var selectedImagePath: String?
    var book: BookModel?
    var bookId: UUID?

    init(bookId: UUID? = nil) {
        self.bookId = bookId
        super.init(nibName: nil, bundle: nil)
        if let bookId = bookId {
            self.bookId = bookId
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.black
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.title = L.book()

        let backButton = UIBarButtonItem(customView: createBackButton())
        navigationItem.leftBarButtonItem = backButton

        setupUI()
        starRatingControl.updateStarSize(to: 14)
        starRatingControl.updateStarSpacing(to: 4)
        configure(with: book)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        view.backgroundColor = .clear
        backgroundImageView.image = R.image.launch_background()

        upperImageView.do { make in
            make.image = R.image.fav_image_placeholder()
            make.contentMode = .center
            make.clipsToBounds = true
            make.isUserInteractionEnabled = true

            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)

            upperImageView.addSubview(blurEffectView)

            blurEffectView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        bookImageView.do { make in
            make.image = R.image.fav_image_placeholder()
            make.contentMode = .scaleAspectFill
            make.clipsToBounds = true
            make.isUserInteractionEnabled = true
            make.layer.cornerRadius = 8
        }

        bookTitleLabel.do { make in
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .center
        }

        authorLabel.do { make in
            make.font = .systemFont(ofSize: 16)
            make.textColor = .white.withAlphaComponent(0.6)
            make.textAlignment = .center
        }

        aboutBookLabel.do { make in
            make.font = .systemFont(ofSize: 20, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .center
        }

        aboutValueLabel.do { make in
            make.font = .systemFont(ofSize: 17)
            make.textColor = .white
            make.numberOfLines = 0
        }

        contentView.subviews.forEach { $0.removeFromSuperview() }

        view.addSubviews(upperImageView, backgroundImageView, bookImageView, bookTitleLabel, authorLabel, starRatingControl, aboutBookLabel, scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubviews(
            aboutValueLabel
        )

        upperImageView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.height.equalTo(277)
        }

        backgroundImageView.snp.makeConstraints { make in
            make.top.equalTo(upperImageView.snp.bottom)
            make.bottom.trailing.leading.equalToSuperview()
        }

        bookImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(7)
            make.centerX.equalToSuperview()
            make.height.equalTo(234)
            make.width.equalTo(162)
        }

        bookTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bookImageView.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(15)
        }

        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(bookTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
        }

        starRatingControl.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalTo(86)
        }

        aboutBookLabel.snp.makeConstraints { make in
            make.top.equalTo(starRatingControl.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(15)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(aboutBookLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        aboutValueLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }
    }

    private func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(L.back(), for: .normal)
        button.setTitleColor(.white, for: .normal)

        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)

        let chevronImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        button.setImage(chevronImage, for: .normal)
        button.tintColor = .white

        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        button.semanticContentAttribute = .forceLeftToRight
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)

        button.frame.size = CGSize(width: 120, height: 44)

        return button
    }

    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }

    private func configure(with model: BookModel?) {
        guard let model = model else { return }
        selectedImagePath = model.bookImagePath
        bookTitleLabel.text = model.bookTitle
        authorLabel.text = model.author
        aboutValueLabel.text = model.note
        customSlider.setSliderValue(value: model.proccess, animated: true)
        starRatingControl.setRating(model.rating)

        if let imagePath = model.bookImagePath, let uuid = UUID(uuidString: imagePath) {
            loadImage(for: uuid) { [weak self] image in
                DispatchQueue.main.async {
                    self?.bookImageView.image = image
                    self?.upperImageView.image = image
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
