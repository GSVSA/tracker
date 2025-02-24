import Foundation

protocol FiltersModelProtocol {
    var object: Filters { get }
    var date: Date? { get }
    var type: FilterType? { get }
    func setDate(_ date: Date)
    func setType(_ type: FilterType)
    func reset()
}

final class FiltersStore: FiltersModelProtocol {
    private let userDefaults = UserDefaults.standard
    private let filterTypeKey = "selectedFilterType"
    private let filterDateKey = "selectedFilterDate"

    var type: FilterType? {
        guard let rawValue = userDefaults.string(forKey: filterTypeKey) else { return nil }
        return FilterType(rawValue: rawValue)
    }

    var date: Date? {
        userDefaults.object(forKey: filterDateKey) as? Date
    }

    var object: Filters {
        .init(date: date, type: type)
    }

    func setType(_ type: FilterType) {
        userDefaults.set(type.rawValue, forKey: filterTypeKey)
        userDefaults.synchronize()
    }

    func setDate(_ date: Date) {
        if date != Date() && type == .today {
            setType(.all)
        }
        userDefaults.set(date, forKey: filterDateKey)
        userDefaults.synchronize()
    }

    func reset() {
        userDefaults.removeObject(forKey: filterTypeKey)
        userDefaults.synchronize()
    }
}
