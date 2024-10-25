import UIKit

protocol OnboardingPageViewControllerDelegate: AnyObject {
    func didUpdateTextFieldState(isFilled: Bool, text: String?)
    func didUpdateSelectedGenres(_ selectedGenres: [Int])
}

final class OnboardingPageViewController: UIViewController {
    // MARK: - Types

    enum Page {
        case name, photo, genres
    }
    
    private let genres = MockGenresData.shared.genres
    private var selectedGenres: [Int] = []

    weak var delegate: OnboardingPageViewControllerDelegate?
    private let nameImageView = UIImageView()
    private let nameView = AppTextFieldView(type: .name)
    private let profileImageView = UIImageView()
    private var selectedImagePath: String?

    private let mainLabel = UILabel()
    private let backgroundImageView = UIImageView()

    private let exitButton = UIButton(type: .custom)

    // MARK: - Properties info

    private let privacyLabel = UILabel()
    private let protectActivityLabel = UILabel()

    private var didAddGradient = false

    private let page: Page
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GenreCell.self, forCellWithReuseIdentifier: GenreCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    // MARK: - Init

    init(page: Page) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textFields = [nameView.textField]
        let textViews = [nameView.textView]
        let textFieldsToMove = [nameView.textField]
        let textViewsToMove = [nameView.textView]

        KeyboardManager.shared.configureKeyboard(
            for: self,
            targetView: view,
            textFields: textFields,
            textViews: textViews,
            moveFor: textFieldsToMove,
            moveFor: textViewsToMove,
            with: .done
        )

        nameView.delegate = self

        switch page {
        case .name: drawName()
        case .photo: drawPhoto()
        case .genres: drawGenres()
        }
    }

    // MARK: - Draw

    private func drawName() {
        backgroundImageView.image = R.image.launch_background()
        backgroundImageView.isUserInteractionEnabled = true
        mainLabel.isHidden = false
        nameImageView.image = R.image.onb_name_image()

        mainLabel.do { make in
            make.text = L.yourName()
            make.textColor = .white
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(backgroundImageView, nameImageView, mainLabel, nameView)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameImageView.snp.makeConstraints { make in
            make.bottom.equalTo(mainLabel.snp.top).offset(-37)
            make.leading.trailing.equalToSuperview().inset(15)
        }

        mainLabel.snp.makeConstraints { make in
            make.bottom.equalTo(nameView.snp.top).offset(-28)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        
        nameView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-117)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(44)
        }
    }
    
    private func setupTextFields() {
        [nameView.textField].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateAddButtonState()
    }
    
    private func updateAddButtonState() {
        let allFieldsFilled = [nameView.textField].allSatisfy { $0.text?.isEmpty == false }
        delegate?.didUpdateTextFieldState(isFilled: allFieldsFilled, text: nameView.textField.text)
    }

    private func drawPhoto() {
        backgroundImageView.image = R.image.launch_background()
        backgroundImageView.isUserInteractionEnabled = true
        
        profileImageView.do { make in
            make.image = R.image.launch_profile_placeholder()
            make.contentMode = .scaleAspectFill
            make.clipsToBounds = true
            make.isUserInteractionEnabled = true
            make.layer.cornerRadius = 111.5
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
            make.addGestureRecognizer(tapGesture)
        }

        mainLabel.do { make in
            make.text = L.yourPhoto()
            make.textColor = .white
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(backgroundImageView, profileImageView, mainLabel)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.bottom.equalTo(mainLabel.snp.top).offset(-158)
            make.centerX.equalToSuperview()
            make.size.equalTo(223)
        }

        mainLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-189)
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
    @objc private func didTapImageView() {
        showImagePickerController()
    }
    
    private func drawGenres() {
        backgroundImageView.image = R.image.launch_background()
        backgroundImageView.isUserInteractionEnabled = true

        mainLabel.do { make in
            make.text = L.selectGenres()
            make.textColor = .white
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(backgroundImageView, mainLabel, collectionView)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(26)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - AppTextFieldDelegate
extension OnboardingPageViewController: AppTextFieldDelegate {
    func didTapTextField(type: AppTextFieldView.TextFieldType) {
        updateAddButtonState()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension OnboardingPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
            let uuid = UUID()
            selectedImagePath = ProfileDataManager.shared.saveImage(selectedImage, withId: uuid)
            if let imagePath = selectedImagePath {
                ProfileDataManager.shared.saveSelectedImagePath(imagePath) 
            }
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (genres.count + 1) / 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let index1 = section * 2
        let index2 = index1 + 1
        
        if index2 < genres.count {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.reuseIdentifier, for: indexPath) as? GenreCell else {
            fatalError("Unable to dequeue CategoryCell")
        }
        
        let genreIndex = indexPath.section * 2 + indexPath.item
        if genreIndex < genres.count {
            let genreItem = genres[genreIndex]
            cell.delegate = self
            cell.configure(with: genreItem)
            cell.isSelected = selectedGenres.contains(genreIndex)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 2) - 8
        let height: CGFloat = 172
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - GenreCellDelegate
extension OnboardingPageViewController: GenreCellDelegate {
    func didTapGenreCell(at index: Int, isSelected: Bool) {
        if isSelected {
            selectedGenres.append(index) 
        } else {
            selectedGenres.removeAll(where: { $0 == index })
        }
        delegate?.didUpdateSelectedGenres(selectedGenres)
    }
}
