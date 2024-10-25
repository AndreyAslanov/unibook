import UIKit

final class ProfileDataManager {
    static let shared = ProfileDataManager()

    private let userDefaults = UserDefaults.standard
    private let nameKey = "profileNameKey"
    private let selectedGenresKey = "selectedGenresKey"
    private let selectedImagePathKey = "selectedImagePathKey"
    
    func saveName(_ name: String) {
        userDefaults.set(name, forKey: nameKey)
    }
    
    func loadName() -> String? {
        return userDefaults.string(forKey: nameKey)
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

    // Load an image from the filesystem by ID
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
    
    func saveSelectedImagePath(_ path: String) {
        userDefaults.set(path, forKey: selectedImagePathKey)
    }

    func loadSelectedImagePath() -> String? {
        return userDefaults.string(forKey: selectedImagePathKey)
    }
    
    // Save a selected ganres
    func saveSelectedGenres(_ genres: [Int]) {
        let genresData = genres.map { String($0) }.joined(separator: ",")
        userDefaults.set(genresData, forKey: selectedGenresKey)
    }

    // Load a selected ganres
    func loadSelectedGenres() -> [Int] {
        guard let genresString = userDefaults.string(forKey: selectedGenresKey) else {
            return []
        }
        return genresString.split(separator: ",").compactMap { Int($0) }
    }
}
