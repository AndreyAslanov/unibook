import Foundation

class LastWeekBooksDataManager {
    static let shared = LastWeekBooksDataManager()

    private let userDefaults = UserDefaults.standard
    private let lastWeekBooksKey = "lastWeekBooks"

    // MARK: - Public Methods

    func saveData(_ name: String) {
        userDefaults.set(name, forKey: lastWeekBooksKey)
    }

    func fetchData() -> String? {
        return userDefaults.string(forKey: lastWeekBooksKey)
    }

    func deleteData() {
        return userDefaults.removeObject(forKey: lastWeekBooksKey)
    }
}
