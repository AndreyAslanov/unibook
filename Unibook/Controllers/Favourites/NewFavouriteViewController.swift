import UIKit

protocol NewFavouriteDelegate: AnyObject {
    func didAddBook(_ book: FavouriteModel)
    func didUpdateBook(_ book: FavouriteModel)
}

final class NewFavouriteViewController: UIViewController {
    private let backgroundImageView = UIImageView()

    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    private let bookImageView = UIImageView()

    private let bookTitleView = AppTextFieldView(type: .bookTitle)
    private let authorView = AppTextFieldView(type: .author)
    private let genreView = AppTextFieldView(type: .genre)
    private let feedbackView = AppTextFieldView(type: .feedback)

    private let proccessLabel = UILabel()
    private let customSlider = CustomSlider()
    var sliderIndex: Int?

    private let ratingLabel = UILabel()
    private let starRatingControl = StarRatingControl()
    var ratingIndex: Int?

    private let saveButton = OnboardingButton()

    private var selectedImagePath: String?
    weak var delegate: NewFavouriteDelegate?
    var book: FavouriteModel?
    var bookId: UUID?
    private var isEditingMode: Bool
    var bookGenre: Int?

    init(bookId: UUID? = nil, isEditing: Bool) {
        self.bookId = bookId
        isEditingMode = isEditing
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
        navigationItem.title = isEditingMode ? L.edit() : L.newFavoriteBook()

        let backButton = UIBarButtonItem(customView: createBackButton())
        navigationItem.leftBarButtonItem = backButton

        setupUI()
        setupTextFields()
        setupTextView()
        updateAddButtonState()

        if isEditingMode {
            configure(with: book)
        }

        let textFields = [
            bookTitleView.textField,
            authorView.textField,
            genreView.textField
        ]

        let textViews = [
            feedbackView.textView
        ]

        let textFieldsToMove = [
            bookTitleView.textField,
            authorView.textField,
            genreView.textField
        ]

        let textViewsToMove = [
            feedbackView.textView
        ]

        KeyboardManager.shared.configureKeyboard(
            for: self,
            targetView: view,
            textFields: textFields,
            textViews: textViews,
            moveFor: textFieldsToMove,
            moveFor: textViewsToMove,
            with: .done
        )

        bookTitleView.delegate = self
        authorView.delegate = self
        genreView.delegate = self
        feedbackView.delegate = self
        customSlider.delegate = self
        starRatingControl.delegate = self

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = true
        starRatingControl.isUserInteractionEnabled = true
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        view.backgroundColor = .clear
        backgroundImageView.image = R.image.launch_background()

        saveButton.setTitle(to: L.save())
        let saveTapGesture = UITapGestureRecognizer(target: self, action: isEditingMode ? #selector(didTapEdit) : #selector(didTapAdd))
        saveButton.addGestureRecognizer(saveTapGesture)

        bookImageView.do { make in
            make.image = R.image.fav_image_placeholder()
            make.contentMode = .scaleAspectFill
            make.clipsToBounds = true
            make.isUserInteractionEnabled = true
            make.layer.cornerRadius = 8
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
            make.addGestureRecognizer(tapGesture)
        }

        proccessLabel.do { make in
            make.text = L.proccess()
            make.font = .systemFont(ofSize: 17)
            make.textColor = .white
            make.textAlignment = .left
        }

        ratingLabel.do { make in
            make.text = L.rating()
            make.font = .systemFont(ofSize: 17)
            make.textColor = .white
            make.textAlignment = .left
        }

        contentView.subviews.forEach { $0.removeFromSuperview() }

        view.addSubviews(backgroundImageView, scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubviews(
            bookImageView, bookTitleView, authorView, genreView, feedbackView,
            proccessLabel, customSlider, ratingLabel, starRatingControl, saveButton
        )

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        bookImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(1)
            make.centerX.equalToSuperview()
            make.height.equalTo(117)
            make.width.equalTo(80)
        }

        bookTitleView.snp.makeConstraints { make in
            make.top.equalTo(bookImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(44)
        }

        authorView.snp.makeConstraints { make in
            make.top.equalTo(bookTitleView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(44)
        }

        genreView.snp.makeConstraints { make in
            make.top.equalTo(authorView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(44)
        }

        feedbackView.snp.makeConstraints { make in
            make.top.equalTo(genreView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(166)
        }

        proccessLabel.snp.makeConstraints { make in
            make.top.equalTo(feedbackView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(15)
        }

        customSlider.snp.makeConstraints { make in
            make.top.equalTo(proccessLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(44)
        }

        ratingLabel.snp.makeConstraints { make in
            make.top.equalTo(customSlider.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(15)
        }

        starRatingControl.snp.makeConstraints { make in
            make.top.equalTo(ratingLabel.snp.bottom).offset(7)
            make.centerX.equalToSuperview()
            make.height.equalTo(39)
            make.width.equalTo(240)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(starRatingControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(45)
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

    private func setupTextFields() {
        [bookTitleView.textField,
         authorView.textField,
         genreView.textField].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    private func setupTextView() {
        feedbackView.textView.delegate = self
    }

    private func updateAddButtonState() {
        let allFieldsFilled = [
            bookTitleView.textField,
            authorView.textField,
            genreView.textField
        ].allSatisfy {
            $0.text?.isEmpty == false
        }

        let feedbackFilled = !feedbackView.textView.text.isEmpty

        saveButton.isEnabled = allFieldsFilled && feedbackFilled
        saveButton.alpha = saveButton.isEnabled ? 1.0 : 0.5
    }

    private func saveMember() {
        guard let bookTitle = bookTitleView.textField.text,
              let author = authorView.textField.text,
              let genre = genreView.textField.text,
              let feedback = feedbackView.textView.text,
              let proccess = sliderIndex,
              let rating = ratingIndex,
              let genreIndex = bookGenre else { return }

        let id = UUID()

        book = FavouriteModel(
            id: id,
            bookTitle: bookTitle,
            author: author,
            genre: genre,
            feedback: feedback,
            proccess: proccess,
            rating: rating,
            genreIndex: genreIndex,
            favImagePath: selectedImagePath
        )
    }

    @objc private func didTapAdd() {
        saveMember()
        if let book = book {
            if let existingBookIndex = loadBooks().firstIndex(where: { $0.id == book.id }) {
                delegate?.didAddBook(book)
            } else {
                delegate?.didAddBook(book)
            }
        } else {
            print("favModel is nil in didTapAdd")
        }
        didTapBack()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateAddButtonState()
    }

    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapEdit() {
        guard let bookId = bookId else {
            print("No bookId provided")
            return
        }

        let updatedBookTitle = bookTitleView.textField.text ?? ""
        let updatedAuthor = authorView.textField.text ?? ""
        let updatedGenre = genreView.textField.text ?? ""
        let updatedFeedback = feedbackView.textView.text ?? ""
        let updatedProccess = sliderIndex
        let updatedRating = ratingIndex

        FavouriteDataManager.shared.updateBook(
            withId: bookId,
            bookTitle: updatedBookTitle,
            author: updatedAuthor,
            genre: updatedGenre,
            feedback: updatedFeedback,
            proccess: updatedProccess,
            rating: updatedRating,
            favImagePath: selectedImagePath
        )

        if let updatedBook = FavouriteDataManager.shared.loadBook(withId: bookId) {
            delegate?.didUpdateBook(updatedBook)
        } else {
            print("Failed to load updated member")
        }

        didTapBack()
    }

    @objc private func didTapImageView() {
        showImagePickerController()
    }

    // MARK: - Data Persistence Methods
    private func loadBooks() -> [FavouriteModel] {
        return FavouriteDataManager.shared.loadBooks()
    }

    private func configure(with model: FavouriteModel?) {
        guard let model = model else { return }
        selectedImagePath = model.favImagePath
        bookTitleView.textField.text = model.bookTitle
        authorView.textField.text = model.author
        genreView.textField.text = model.genre
        feedbackView.textView.text = model.feedback
        feedbackView.placeholderLabel.isHidden = !model.feedback.isEmpty
        customSlider.setSliderValue(value: model.proccess, animated: true)
        starRatingControl.setRating(model.rating)

        if let imagePath = model.favImagePath, let uuid = UUID(uuidString: imagePath) {
            loadImage(for: uuid) { [weak self] image in
                DispatchQueue.main.async {
                    self?.bookImageView.image = image
                    if image == nil {
                        print("Failed to load image for UUID: \(imagePath)")
                    }
                }
            }
        }

        updateAddButtonState()
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

// MARK: - AppTextFieldDelegate
extension NewFavouriteViewController: AppTextFieldDelegate {
    func didTapTextField(type: AppTextFieldView.TextFieldType) {
        updateAddButtonState()
    }
}

// MARK: - UITextViewDelegate
extension NewFavouriteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateAddButtonState()
    }
}

// MARK: - CustomSliderDelegate
extension NewFavouriteViewController: CustomSliderDelegate {
    func sliderValueDidChange(_ slider: CustomSlider, value: Int) {
        sliderIndex = value
    }
}

// MARK: - StarRatingControlDelegate
extension NewFavouriteViewController: StarRatingControlDelegate {
    func starRatingDidChange(rating: Int) {
        ratingIndex = rating
    }
}

// MARK: - UIImagePickerControllerDelegate
extension NewFavouriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            bookImageView.image = selectedImage
            selectedImagePath = FavouriteDataManager.shared.saveImage(selectedImage, withId: UUID())
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - KeyBoard Apparance
extension NewFavouriteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewFavouriteViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillShow(notification as Notification)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillHide(notification as Notification)
    }
}
