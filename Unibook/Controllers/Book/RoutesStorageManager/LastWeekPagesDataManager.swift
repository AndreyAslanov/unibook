import Foundation

class LastWeekPagesDataManager {
    static let shared = LastWeekPagesDataManager()

    private let userDefaults = UserDefaults.standard
    private let lastWeekPagesKey = "lastWeekPages"

    // MARK: - Public Methods

    func saveData(_ name: String) {
        userDefaults.set(name, forKey: lastWeekPagesKey)
    }

    func fetchData() -> String? {
        return userDefaults.string(forKey: lastWeekPagesKey)
    }

    func deleteData() {
        return userDefaults.removeObject(forKey: lastWeekPagesKey)
    }
}
