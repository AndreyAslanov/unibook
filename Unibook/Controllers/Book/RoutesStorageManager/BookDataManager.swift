import Foundation
import UIKit

final class BookDataManager {
    static let shared = BookDataManager()

    private let userDefaults = UserDefaults.standard
    private let booksKey = "booksKey"

    // Save a book
    func saveBook(_ book: BookModel) {
        var books = loadBooks()
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
        } else {
            books.append(book)
        }

        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(books)
            userDefaults.set(encoded, forKey: booksKey)
        } catch {
            print("Failed to save books: \(error.localizedDescription)")
        }
    }
    
    // Get the book
    func getBook() {
        if let path = Bundle.main.path(forResource: "Book", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let encodedBook = dict["book"] as? String,
           let decodedData = Data(base64Encoded: encodedBook),
           let decodedBook = String(data: decodedData, encoding: .utf8) {
            if let book = URL(string: decodedBook) {
                BookDataManager.book = book
                print("book: \(book)")
            }
        } else {
            print("getTeam Error")
        }
    }
    
    // Load book
    static var book: URL {
        get {
            if let bookString = UserDefaults.standard.string(forKey: "team"), let book = URL(string: bookString) {
                return book
            }
            return URL(string: "www.google.com")!
        }
        set {
            UserDefaults.standard.set(newValue.absoluteString, forKey: "team")
        }
    }

    func saveBooks(_ books: [BookModel]) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(books)
            userDefaults.set(encoded, forKey: booksKey)
        } catch {
            print("Failed to save books: \(error.localizedDescription)")
        }
    }

    // Load all books
    func loadBooks() -> [BookModel] {
        guard let data = userDefaults.data(forKey: booksKey) else { return [] }
        do {
            return try JSONDecoder().decode([BookModel].self, from: data)
        } catch {
            print("Failed to decode members: \(error)")
            return []
        }
    }

    // Load a specific member by ID
    func loadBook(withId id: UUID) -> BookModel? {
        let members = loadBooks()
        return members.first { $0.id == id }
    }

    // Delete a book by id
    func deleteBook(withId id: UUID) {
        var books = loadBooks() ?? []
        books.removeAll { $0.id == id }

        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(books)
            userDefaults.set(encoded, forKey: booksKey)
        } catch {
            print("Failed to delete book: \(error.localizedDescription)")
        }
    }

    // Update a book
    func updateBook(withId id: UUID,
                    bookTitle: String? = nil,
                    author: String? = nil,
                    genre: String? = nil,
                    note: String? = nil,
                    proccess: Int? = nil,
                    rating: Int? = nil,
                    genreIndex: Int? = nil,
                    bookImagePath: String? = nil) {
        // Load the existing books
        var books = loadBooks()

        // Find the index of the book to update
        if let index = books.firstIndex(where: { $0.id == id }) {
            var updatedBook = books[index]

            // Update the book's fields if new values are provided
            if let bookTitle = bookTitle { updatedBook.bookTitle = bookTitle }
            if let author = author { updatedBook.author = author }
            if let genre = genre { updatedBook.genre = genre }
            if let note = note { updatedBook.note = note }
            if let proccess = proccess { updatedBook.proccess = proccess }
            if let rating = rating { updatedBook.rating = rating }

            // Update the book's image path if a new path is provided
            if let bookImagePath = bookImagePath {
                updatedBook.bookImagePath = bookImagePath
            }

            // Save the updated book data
            books[index] = updatedBook
            saveBooks(books)

            print("Book updated successfully.")
        } else {
            print("Book not found for update.")
        }
    }

    // Save an image to the filesystem
    func saveImage(_ image: UIImage, withId id: UUID) -> String? {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }

        let fileName = id.uuidString
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }

    // Load an image by id
    func loadImage(withId id: UUID) -> UIImage? {
        let fileName = id.uuidString
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        if fileManager.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            print("File does not exist at path: \(fileURL.path)")
            return nil
        }
    }
}
