import SnapKit
import UIKit

final class ProfileViewController: UIViewController {
    private let backgroundImageView = UIImageView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let favouriteLabel = UILabel()
    private let noDataLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var selectedImagePath: String?
    
    private let settingsStackView = UIStackView()
    
    private let shareAppView: SettingsView
    private let usagePolicyView: SettingsView
    private let rateAppView: SettingsView
    
    private let genres = MockGenresData.shared.genres
    private var selectedGenres: [Int] = []
    private var filteredGenres: [GenreModel] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GenreCell.self, forCellWithReuseIdentifier: GenreCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    init() {
        shareAppView = SettingsView(type: .shareApp)
        usagePolicyView = SettingsView(type: .usagePolicy)
        rateAppView = SettingsView(type: .rateApp)
        
        super.init(nibName: nil, bundle: nil)
        
        shareAppView.delegate = self
        usagePolicyView.delegate = self
        rateAppView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
        loadSelectedGenres()
        updateVisibility()
        collectionView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarAppearance = UINavigationBar.appearance()
            navigationBarAppearance.barTintColor = UIColor.black
            navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        let rightButton = UIBarButtonItem(image: R.image.profile_edit_button(), style: .plain, target: self, action: #selector(rightButtonTapped))
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = rightButton
        
        view.backgroundColor = .clear
        
        drawself()
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        configure()
        loadSelectedGenres()
        updateVisibility()
        collectionView.reloadData()
    }

    private func drawself() {
        backgroundImageView.image = R.image.launch_background()
        profileImageView.do { make in
            make.image = R.image.launch_profile_placeholder()
            make.contentMode = .scaleAspectFill
            make.clipsToBounds = true
            make.isUserInteractionEnabled = true
            make.layer.cornerRadius = 111.5
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
            make.addGestureRecognizer(tapGesture)
        }
        
        nameLabel.do { make in
            make.text = L.yourName()
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.textColor = .white
            make.textAlignment = .center
        }
        
        favouriteLabel.do { make in
            make.text = L.favoriteGenres()
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white.withAlphaComponent(0.4)
            make.textAlignment = .left
        }        
        
        noDataLabel.do { make in
            make.text = L.noData()
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .right
        }
        
        settingsStackView.do { make in
            make.axis = .vertical
            make.spacing = 14
            make.distribution = .equalSpacing
        }

        settingsStackView.addArrangedSubviews(
            [usagePolicyView, rateAppView, shareAppView]
        )
        
        view.addSubviews(backgroundImageView, scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            profileImageView, nameLabel, favouriteLabel, noDataLabel, collectionView, settingsStackView
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

        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(223)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(31)
            make.centerX.equalToSuperview()
        }
        
        favouriteLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(19)
            make.leading.equalToSuperview().offset(15)
        }
        
        noDataLabel.snp.makeConstraints { make in
            make.centerY.equalTo(favouriteLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(17)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(favouriteLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(180)
        }
        
        settingsStackView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalTo(contentView.snp.bottom).offset(-60)
        }
        
        [shareAppView, usagePolicyView, rateAppView].forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(45)
            }
        }
    }
    
    private func loadSelectedGenres() {
        selectedGenres = ProfileDataManager.shared.loadSelectedGenres()

        filteredGenres = genres.compactMap { genre in
            var genreItem = genre
            genreItem.isSelected = selectedGenres.contains(genre.index)
            return genreItem.isSelected ? genreItem : nil
        }
    }

    private func updateVisibility() {
        noDataLabel.isHidden = !filteredGenres.isEmpty
    }
    
    @objc private func didTapImageView() {
        showImagePickerController()
    }
    
    @objc private func rightButtonTapped() {
        let editProfileVC = EditProfileViewController()
        editProfileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    private func configure() {
        if let savedName = ProfileDataManager.shared.loadName() {
            nameLabel.text = savedName
        }
        
        selectedImagePath = ProfileDataManager.shared.loadSelectedImagePath()
        
        if let imagePath = selectedImagePath, let uuid = UUID(uuidString: imagePath) {
            loadImage(for: uuid) { [weak self] image in
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                    if image == nil {
                        print("Failed to load image for UUID: \(imagePath)")
                    }
                }
            }
        } else {
            print("No image path available or invalid UUID.")
        }
    }

    private func loadImage(for id: UUID, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let image = ProfileDataManager.shared.loadImage(withId: id)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            if let imagePath = ProfileDataManager.shared.saveImage(selectedImage, withId: uuid) {
                selectedImagePath = imagePath
                ProfileDataManager.shared.saveSelectedImagePath(imagePath)
            } else {
                print("Error saving image.")
            }
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - ProfileViewDelegate
extension ProfileViewController: SettingsViewDelegate {
    func didTapView(type: SettingsView.SelfType) {
        switch type {
        case .shareApp:
            AppActions.shared.shareApp()
        case .usagePolicy:
            AppActions.shared.showUsagePolicy()
        case .rateApp:
            AppActions.shared.rateApp()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredGenres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.reuseIdentifier, for: indexPath) as? GenreCell else {
            fatalError("Unable to dequeue GenreCell")
        }
        
        let genreItem = filteredGenres[indexPath.item]
        cell.configure(with: genreItem)
        cell.isUserInteractionEnabled = false
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 157
        let height: CGFloat = 172
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
