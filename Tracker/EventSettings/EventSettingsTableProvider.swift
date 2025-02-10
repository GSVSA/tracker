import UIKit

struct EventSettingsCellModel: SettingsTableItem {
    let title: String
    let subtitle: String?
    let destination: UIViewController.Type
    let isSelected: Bool?

    init(title: String, subtitle: String? = nil, destination: UIViewController.Type) {
        self.title = title
        self.subtitle = subtitle
        self.destination = destination
        self.isSelected = false
    }
}

private let categoryCellConfig = EventSettingsCellModel(title: "Категория", destination: CategoryViewController.self)
private let scheduleCellConfig = EventSettingsCellModel(title: "Расписание", destination: ScheduleViewController.self)

final class EventSettingsTableProvider: SettingsTableProvider {
    var cellConfig: CellConfig? = .init(accessoryType: .disclosureIndicator)

    var numberOfSections: Int { 1 }

    private(set) var cellConfigs: [EventSettingsCellModel] = [categoryCellConfig, scheduleCellConfig]

    private(set)  var isIrregular: Bool = false

    func numberOfRowsInSection(_ section: Int) -> Int { cellConfigs.count }

    func find(at indexPath: IndexPath) -> SettingsTableItem? {
        cellConfigs[indexPath.item]
    }

    func setIsIrregular(_ isIrregular: Bool) {
        self.isIrregular = isIrregular
    }

    func updateData(selectedCategory: String?, selectedSchedule: String?) {
        let categoryConfig = EventSettingsCellModel(
            title: categoryCellConfig.title,
            subtitle: selectedCategory,
            destination: categoryCellConfig.destination
        )
        let scheduleConfig = EventSettingsCellModel(
            title: scheduleCellConfig.title,
            subtitle: selectedSchedule,
            destination: scheduleCellConfig.destination
        )
        if isIrregular {
            cellConfigs = [categoryConfig]
        } else {
            cellConfigs = [categoryConfig, scheduleConfig]
        }
    }
}
