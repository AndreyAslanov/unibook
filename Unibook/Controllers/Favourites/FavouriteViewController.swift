import SnapKit
import UIKit

final class FavouriteViewController: UIViewController {
    private let backgroungImageView = UIImageView()
    private let favoriteBooksLabel = UILabel()
    private let genresLabel = UILabel()

    private let genreSelectionView = GenreSelectionView()
    private let scrollView = UIScrollView()
    var selectedGenre: Int? = 0

    private let newFavouriteView = NewFavouriteView()

   private var books: [FavouriteModel] = [] {
        didSet {
            saveBooks(books)
        }
    }

    var filteredBooks: [FavouriteModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FavCell.self, forCellWithReuseIdentifier: FavCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        newFavouriteView.delegate = self
        genreSelectionView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.black
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        setupRightBarButton()

        view.backgroundColor = .clear

        drawself()
        books = loadBooks()
        genreSelectionView.configureForCell(selectedIndex: 0)
        filterBooksByGenre()
        updateViewVisibility()
    }

    private func drawself() {
        backgroungImageView.image = R.image.launch_background()

        favoriteBooksLabel.do { make in
            make.text = L.favoriteBooks()
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.textColor = .white
            make.textAlignment = .left
        }

        genresLabel.do { make in
            make.text = L.genres()
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .left
        }

        scrollView.do { make in
            make.showsVerticalScrollIndicator = false
            make.showsHorizontalScrollIndicator = false
        }

        scrollView.addSubview(genreSelectionView)

        view.addSubviews(
            backgroungImageView, favoriteBooksLabel, genresLabel, scrollView, collectionView, newFavouriteView
        )

        backgroungImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        favoriteBooksLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(13.5)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-5)
        }

        genresLabel.snp.makeConstraints { make in
            make.top.equalTo(favoriteBooksLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(genresLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(172)
        }

        genreSelectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
            make.width.equalTo(1972)
        }

        newFavouriteView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(360)
            make.height.equalTo(180)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }

    private func updateViewVisibility() {
        let isEmpty = filteredBooks.isEmpty
        newFavouriteView.isHidden = !isEmpty
    }

    private func setupRightBarButton() {
        let customButtonView = createCustomButton()

        let barButtonItem = UIBarButtonItem(customView: customButtonView)
        navigationItem.rightBarButtonItem = barButtonItem
    }

    private func createCustomButton() -> UIView {
        let customButtonView = UIView()
        customButtonView.backgroundColor = .white
        customButtonView.layer.cornerRadius = 12
        customButtonView.clipsToBounds = true

        let iconImageView = UIImageView(image: UIImage(systemName: "plus.square.fill"))
        iconImageView.tintColor = .black
        iconImageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = L.addBook()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)

        let stackView = UIStackView(arrangedSubviews: [iconImageView, label])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center

        customButtonView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14.5)
            make.centerY.equalToSuperview()
        }

        customButtonView.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.width.equalTo(140)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(customButtonTapped))
        customButtonView.addGestureRecognizer(tapGesture)

        return customButtonView
    }

    private func filterBooksByGenre() {
        if let selectedGenre = selectedGenre {
            filteredBooks = books.filter { $0.genreIndex == selectedGenre }
        } else {
            filteredBooks = books
        }
    }

    @objc private func customButtonTapped() {
        didTapPlusButton()
    }

    @objc private func didTapPlusButton() {
        let newBookVC = NewFavouriteViewController(isEditing: false)
        newBookVC.delegate = self
        newBookVC.bookGenre = selectedGenre

        let navigationController = UINavigationController(rootViewController: newBookVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .coverVertical

        present(navigationController, animated: true, completion: nil)
    }

    // MARK: - Data Persistence Methods
    private func loadBooks() -> [FavouriteModel] {
        return FavouriteDataManager.shared.loadBooks()
    }

    private func saveBooks(_ models: [FavouriteModel]) {
        FavouriteDataManager.shared.saveBooks(models)
    }
}

// MARK: - NewBookViewDelegate
extension FavouriteViewController: NewFavouriteViewDelegate {
    func didTapFavButton() {
        didTapPlusButton()
    }
}

// MARK: - NewFavouriteDelegate
extension FavouriteViewController: NewFavouriteDelegate {
    func didAddBook(_ book: FavouriteModel) {
        books.append(book)
        filterBooksByGenre()
        updateViewVisibility()
    }

    func didUpdateBook(_ book: FavouriteModel) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            filterBooksByGenre()
        }
        updateViewVisibility()
    }
}

// MARK: - BookCellDelegate
extension FavouriteViewController: FavCellDelegate {
    func didTapEditButton(with book: FavouriteModel) {
        let newBookVC = NewFavouriteViewController(isEditing: true)
        newBookVC.delegate = self
        newBookVC.bookGenre = book.genreIndex
        newBookVC.book = book
        newBookVC.bookId = book.id

        let navigationController = UINavigationController(rootViewController: newBookVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .coverVertical

        present(navigationController, animated: true, completion: nil)
    }

    func didTapDeleteButton(with book: FavouriteModel) {
        let alertController = UIAlertController(title: L.remove(), message: L.deleteBook(), preferredStyle: .alert)
        let closeAction = UIAlertAction(title: L.cancel(), style: .default, handler: nil)
        let deleteAction = UIAlertAction(title: L.delete(), style: .destructive) { [weak self] _ in
            let bookId = book.id

            FavouriteDataManager.shared.deleteBook(withId: bookId)
            self?.didDeleteBook(withId: bookId)
        }

        alertController.addAction(closeAction)
        alertController.addAction(deleteAction)
        alertController.view.tintColor = UIColor(hex: "#0A84FF")
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }

    func didDeleteBook(withId bookId: UUID) {
        if let index = books.firstIndex(where: { $0.id == bookId }) {
            books.remove(at: index)
            filterBooksByGenre()
            updateViewVisibility()
        }
    }
}

// MARK: - GenreSelectionDelegate
extension FavouriteViewController: GenreSelectionDelegate {
    func didSelectGenre(selectedIndex: Int) {
        selectedGenre = selectedIndex
        filterBooksByGenre()
        updateViewVisibility()
    }
}

// MARK: - UICollectionViewDataSource
extension FavouriteViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredBooks.isEmpty ? 0 : filteredBooks.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section < filteredBooks.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavCell.reuseIdentifier, for: indexPath) as? FavCell else {
                fatalError("Unable to dequeue RoutersPermanentCell")
            }
            let books = filteredBooks[indexPath.section]
            cell.delegate = self
            cell.configure(with: books)
            return cell
        }

        return collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 216
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
}
