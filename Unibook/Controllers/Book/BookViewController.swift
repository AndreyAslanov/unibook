import SnapKit
import UIKit

final class BookViewController: UIViewController {
    private let backgroungImageView = UIImageView()
    private let booksLabel = UILabel()
    private let lastMonthView = LastMonthView()
    private let bookSelectionView = BookSelectionView()
    private let newBookView = NewBookView()
    private var selectionType: Int? = 0

    private lazy var overlayView = UIView(frame: self.view.bounds)

    private var books: [BookModel] = [] {
        didSet {
            saveBooks(books)
        }
    }

    private var filteredBooks: [BookModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: BookCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.black
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        setupRightBarButton()
        view.backgroundColor = .clear

        drawself()
        lastMonthView.delegate = self
        bookSelectionView.delegate = self
        newBookView.delegate = self

        if let bookName = LastWeekBooksDataManager.shared.fetchData() {
            lastMonthView.configureBookValueLabel(with: bookName)
        }

        if let pagesName = LastWeekPagesDataManager.shared.fetchData() {
            lastMonthView.configurePageValueLabel(with: pagesName)
        }

        bookSelectionView.configure(selectedIndex: 0)
        books = loadBooks()
        updateFilteredBooks()
        updateViewVisibility()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewVisibility()
    }

    private func drawself() {
        backgroungImageView.image = R.image.launch_background()

        booksLabel.do { make in
            make.text = L.books()
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.textColor = .white
            make.textAlignment = .left
        }

        view.addSubviews(
            backgroungImageView, booksLabel, lastMonthView, bookSelectionView, collectionView, newBookView
        )

        backgroungImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        booksLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(13.5)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-5)
        }

        lastMonthView.snp.makeConstraints { make in
            make.top.equalTo(booksLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(193)
        }

        bookSelectionView.snp.makeConstraints { make in
            make.top.equalTo(lastMonthView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(31)
        }

        newBookView.snp.makeConstraints { make in
            make.top.equalTo(bookSelectionView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(360)
            make.height.equalTo(180)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(bookSelectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
        }
    }

    private func updateViewVisibility() {
        let isEmpty = filteredBooks.isEmpty
        newBookView.isHidden = !isEmpty
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

    private func updateFilteredBooks() {
        if selectionType == 1 {
            filteredBooks = books.filter { $0.proccess == 100 }
        } else if selectionType == 0 {
            filteredBooks = books.filter { $0.proccess < 100 }
        }
    }

    @objc private func customButtonTapped() {
        didTapAddBookButton()
    }

    @objc private func didTapAddBookButton() {
        let newBookVC = NewBookViewController(isEditing: false)
        newBookVC.delegate = self

        let navigationController = UINavigationController(rootViewController: newBookVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .coverVertical

        present(navigationController, animated: true, completion: nil)
    }

    // MARK: - Data Persistence Methods
    private func loadBooks() -> [BookModel] {
        return BookDataManager.shared.loadBooks()
    }

    private func saveBooks(_ models: [BookModel]) {
        BookDataManager.shared.saveBooks(models)
    }
}

// MARK: - LastMonthViewDelegate
extension BookViewController: LastMonthViewDelegate {
    func didTapBookButton() {
        let alertController = UIAlertController(title: L.numberBooks(), message: L.trackProgress(), preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "0"
            textField.keyboardType = .phonePad
        }

        let cancelAction = UIAlertAction(title: L.close(), style: .default, handler: nil)

        let saveAction = UIAlertAction(title: L.save(), style: .cancel) { _ in
            guard let nameText = alertController.textFields?[0].text,
                  !nameText.isEmpty else {
                return
            }

            LastWeekBooksDataManager.shared.saveData(nameText)
            self.lastMonthView.configureBookValueLabel(with: nameText)
        }

        saveAction.setValue(UIColor(hex: "#0A84FF"), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }

    func didTapPageButton() {
        let alertController = UIAlertController(title: L.numberBooks(), message: L.trackProgress(), preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "0"
            textField.keyboardType = .phonePad
        }

        let cancelAction = UIAlertAction(title: L.close(), style: .default, handler: nil)

        let saveAction = UIAlertAction(title: L.save(), style: .cancel) { _ in
            guard let nameText = alertController.textFields?[0].text,
                  !nameText.isEmpty else {
                return
            }

            LastWeekPagesDataManager.shared.saveData(nameText)
            self.lastMonthView.configurePageValueLabel(with: nameText)
        }

        saveAction.setValue(UIColor(hex: "#0A84FF"), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.overrideUserInterfaceStyle = .dark

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - NewBookViewDelegate
extension BookViewController: NewBookViewDelegate {
    func didTapButton() {
        didTapAddBookButton()
    }
}

// MARK: - BookSelectionDelegate
extension BookViewController: BookSelectionDelegate {
    func didSelectType(at index: Int) {
        selectionType = index
        updateFilteredBooks()
    }
}

// MARK: - NewBookDelegate
extension BookViewController: NewBookDelegate {
    func didAddBook(_ book: BookModel) {
        books.append(book)
        updateFilteredBooks()
        updateViewVisibility()
    }

    func didUpdateBook(_ book: BookModel) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            updateFilteredBooks()
        }
        updateViewVisibility()
    }
}

// MARK: - NewRaceDelegate
extension BookViewController: BookCellDelegate {
    func didTapCell(with book: BookModel) {
        let bookProfileVC = BookProfileViewController()
        bookProfileVC.book = book
        bookProfileVC.bookId = book.id

        let navigationController = UINavigationController(rootViewController: bookProfileVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .coverVertical

        present(navigationController, animated: true, completion: nil)
    }

    func didTapEditButton(with book: BookModel) {
        let newBookVC = NewBookViewController(isEditing: true)
        newBookVC.delegate = self
        newBookVC.book = book
        newBookVC.bookId = book.id

        let navigationController = UINavigationController(rootViewController: newBookVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .coverVertical

        present(navigationController, animated: true, completion: nil)
    }

    func didTapDeleteButton(with book: BookModel) {
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
            updateFilteredBooks()
            updateViewVisibility()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension BookViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredBooks.isEmpty ? 0 : filteredBooks.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section < filteredBooks.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.reuseIdentifier, for: indexPath) as? BookCell else {
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
        let height: CGFloat = 132
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
}
