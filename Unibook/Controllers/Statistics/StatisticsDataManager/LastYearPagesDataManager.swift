import Foundation

class LastYearPagesDataManager {
    static let shared = LastYearPagesDataManager()

    private let userDefaults = UserDefaults.standard
    private let lastYearPagesKey = "lastYearPages"

    // MARK: - Public Methods

    func saveData(_ name: String) {
        userDefaults.set(name, forKey: lastYearPagesKey)
    }

    func fetchData() -> String? {
        return userDefaults.string(forKey: lastYearPagesKey)
    }

    func deleteData() {
        return userDefaults.removeObject(forKey: lastYearPagesKey)
    }
}
