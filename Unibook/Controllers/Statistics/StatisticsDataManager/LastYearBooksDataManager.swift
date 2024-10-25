import Foundation

class LastYearBooksDataManager {
    static let shared = LastYearBooksDataManager()

    private let userDefaults = UserDefaults.standard
    private let lastYearBooksKey = "lastYearBooks"

    // MARK: - Public Methods

    func saveData(_ name: String) {
        userDefaults.set(name, forKey: lastYearBooksKey)
    }

    func fetchData() -> String? {
        return userDefaults.string(forKey: lastYearBooksKey)
    }

    func deleteData() {
        return userDefaults.removeObject(forKey: lastYearBooksKey)
    }
}
