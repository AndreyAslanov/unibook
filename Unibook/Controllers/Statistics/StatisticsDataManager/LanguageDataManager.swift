import Foundation

class LanguageDataManager {
    static let shared = LanguageDataManager()

    private let userDefaults = UserDefaults.standard
    private let languageKey = "languageKey"

    // MARK: - Public Methods

    func saveData(_ name: String) {
        userDefaults.set(name, forKey: languageKey)
    }

    func fetchData() -> String? {
        return userDefaults.string(forKey: languageKey)
    }

    func deleteData() {
        return userDefaults.removeObject(forKey: languageKey)
    }
}
