import Foundation

enum StatisticsViewType: String {
    case reading
    case time
    case genre
    case author
}

class StatisticsDataManager {
    static let shared = StatisticsDataManager()

    private let userDefaults = UserDefaults.standard
    private let statisticsKeyPrefix = "statistics_"

    // MARK: - Public Methods

    func saveData(_ type: StatisticsViewType, value: String) {
        let key = statisticsKey(for: type)
        userDefaults.set(value, forKey: key)
    }

    func fetchData(for type: StatisticsViewType) -> String? {
        let key = statisticsKey(for: type)
        return userDefaults.string(forKey: key)
    }

    func deleteData(for type: StatisticsViewType) {
        let key = statisticsKey(for: type)
        userDefaults.removeObject(forKey: key)
    }

    // MARK: - Private Methods

    private func statisticsKey(for type: StatisticsViewType) -> String {
        return statisticsKeyPrefix + type.rawValue
    }
}
