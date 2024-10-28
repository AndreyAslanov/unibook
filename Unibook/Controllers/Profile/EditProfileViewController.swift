import SnapKit
import UIKit

final class EditProfileViewController: UIViewController {
    private let backgroundImageView = UIImageView()
    private let nameView = AppTextFieldView(type: .name)
    private let selectLabel = UILabel()
    private let saveButton = OnboardingButton()

    private let genres = MockGenresData.shared.genres
    private var selectedGenres: [Int] = []
    private var filteredGenres: [GenreModel] = []

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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = L.edit()
        let backButton = UIBarButtonItem(customView: createBackButton())
        navigationItem.leftBarButtonItem = backButton

        view.backgroundColor = .clear

        drawself()
        updateAddButtonState()

        loadSelectedGenres()
        collectionView.reloadData()

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
    }

    private func drawself() {
        backgroundImageView.image = R.image.launch_background()
        saveButton.setTitle(to: L.save())
        let saveTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSave))
        saveButton.addGestureRecognizer(saveTapGesture)

        selectLabel.do { make in
            make.text = L.selectGenres()
            make.textColor = .white
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(backgroundImageView, nameView, selectLabel, collectionView, saveButton)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        nameView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(26)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(44)
        }

        selectLabel.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.height.equalTo(41)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(selectLabel.snp.bottom).offset(26)
            make.trailing.leading.equalToSuperview().inset(30)
            make.bottom.equalToSuperview()
        }

        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-1)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(45)
        }
    }

    private func loadSelectedGenres() {
        selectedGenres = ProfileDataManager.shared.loadSelectedGenres()

        filteredGenres = genres.map { genre in
            var genreItem = genre
            genreItem.isSelected = selectedGenres.contains(genre.index)
            return genreItem
        }
    }

    private func setupTextFields() {
        [nameView.textField].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    private func updateAddButtonState() {
        let allFieldsFilled = [nameView.textField].allSatisfy { $0.text?.isEmpty == false }

        saveButton.isEnabled = allFieldsFilled
        saveButton.alpha = allFieldsFilled ? 1.0 : 0.5
    }

    @objc private func didTapSave() {
        ProfileDataManager.shared.saveName(nameView.textField.text ?? L.yourName())
        ProfileDataManager.shared.saveSelectedGenres(selectedGenres)
        backButtonTapped()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateAddButtonState()
    }

    private func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(L.back(), for: .normal)
        button.setTitleColor(.white, for: .normal)

        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)

        let chevronImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        button.setImage(chevronImage, for: .normal)
        button.tintColor = .white

        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        button.semanticContentAttribute = .forceLeftToRight
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)

        button.frame.size = CGSize(width: 120, height: 44)

        return button
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension EditProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let itemsPerRow = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
        return (filteredGenres.count + itemsPerRow - 1) / itemsPerRow
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemsPerRow = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
        let index1 = section * itemsPerRow
        let index2 = index1 + (itemsPerRow - 1)

        if index2 < filteredGenres.count {
            return itemsPerRow
        } else {
            return filteredGenres.count - index1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.reuseIdentifier, for: indexPath) as? GenreCell else {
            fatalError("Unable to dequeue GenreCell")
        }

        let itemsPerRow = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
        let genreIndex = indexPath.section * itemsPerRow + indexPath.item

        if genreIndex < filteredGenres.count {
            let genreItem = filteredGenres[genreIndex]
            cell.delegate = self
            cell.configure(with: genreItem)
            cell.isSelected = selectedGenres.contains(genreIndex)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
        let width = (collectionView.bounds.width / itemsPerRow) - 8
        let height: CGFloat = 172
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - GenreCellDelegate
extension EditProfileViewController: GenreCellDelegate {
    func didTapGenreCell(at index: Int, isSelected: Bool) {
        if isSelected {
            selectedGenres.append(index)
        } else {
            selectedGenres.removeAll(where: { $0 == index })
        }
    }
}

// MARK: - AppTextFieldDelegate
extension EditProfileViewController: AppTextFieldDelegate {
    func didTapTextField(type: AppTextFieldView.TextFieldType) {
        updateAddButtonState()
    }
}
