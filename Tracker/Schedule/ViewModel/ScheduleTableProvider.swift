import UIKit

struct ScheduleCellModel: SettingsTableItem {
    let title: String
    let subtitle: String?
    let isSelected: Bool?

    init(title: String, isSelected: Bool?) {
        self.title = title
        self.subtitle = nil
        self.isSelected = isSelected
    }
}

final class ScheduleTableProvider: SettingsTableProvider {
    var cellConfig: CellConfig? = .init(isSwitcher: true)

    var numberOfSections: Int { 1 }

    private(set) var selectedDays: [Weekday: Bool] = [:]

    func numberOfRowsInSection(_ section: Int) -> Int { Weekday.allCases.count }

    func find(at indexPath: IndexPath) -> SettingsTableItem? {
        let day = Weekday.allCases[indexPath.item]
        return ScheduleCellModel(title: day.translated, isSelected: selectedDays[day])
    }

    func setSelectedDays(_ days: [Weekday]) {
        selectedDays = days.reduce(into: [:]) { result, day in
            result[day] = true
        }
    }

    func updateValue(day: Weekday, value: Bool) {
        selectedDays.updateValue(value, forKey: day)
    }
}
