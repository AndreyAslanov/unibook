import Foundation
import UIKit

final class FavouriteDataManager {
    static let shared = FavouriteDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let favKey = "favKey"
    
    // Save a book
    func saveBook(_ book: FavouriteModel) {
        var books = loadBooks() ?? []
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
        } else {
            books.append(book)
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(books)
            userDefaults.set(encoded, forKey: favKey)
        } catch {
            print("Failed to save books: \(error.localizedDescription)")
        }
    }
    
    func saveBooks(_ books: [FavouriteModel]) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(books)
            userDefaults.set(encoded, forKey: favKey)
        } catch {
            print("Failed to save books: \(error.localizedDescription)")
        }
    }
    
    // Load all books
    func loadBooks() -> [FavouriteModel] {
        guard let data = userDefaults.data(forKey: favKey) else { return [] }
        do {
            return try JSONDecoder().decode([FavouriteModel].self, from: data)
        } catch {
            print("Failed to decode members: \(error)")
            return []
        }
    }
    
    // Load a specific member by ID
    func loadBook(withId id: UUID) -> FavouriteModel? {
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
            userDefaults.set(encoded, forKey: favKey)
        } catch {
            print("Failed to delete book: \(error.localizedDescription)")
        }
    }
    
    // Update a book 
    func updateBook(withId id: UUID,
                    bookTitle: String? = nil,
                    author: String? = nil,
                    genre: String? = nil,
                    feedback: String? = nil,
                    proccess: Int? = nil,
                    rating: Int? = nil,
                    genreIndex: Int? = nil,
                    favImagePath: String? = nil) {
        // Load the existing books
        var books = loadBooks() ?? []
        
        // Find the index of the book to update
        if let index = books.firstIndex(where: { $0.id == id }) {
            var updatedBook = books[index]
            
            // Update the book's fields if new values are provided
            if let bookTitle = bookTitle { updatedBook.bookTitle = bookTitle }
            if let author = author { updatedBook.author = author }
            if let genre = genre { updatedBook.genre = genre }
            if let feedback = feedback { updatedBook.feedback = feedback }
            if let proccess = proccess { updatedBook.proccess = proccess }
            if let rating = rating { updatedBook.rating = rating }
            if let genreIndex = genreIndex { updatedBook.genreIndex = genreIndex }

            // Update the book's image path if a new path is provided
            if let bookImagePath = favImagePath {
                updatedBook.favImagePath = favImagePath
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
