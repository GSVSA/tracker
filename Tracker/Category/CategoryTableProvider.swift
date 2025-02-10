import UIKit

struct CategoryCellModel: SettingsTableItem {
    let title: String
    let subtitle: String?
    let isSelected: Bool?

    init(title: String, isSelected: Bool? = false) {
        self.title = title
        self.subtitle = nil
        self.isSelected = isSelected
    }
}

final class CategoryTableProvider: SettingsTableProvider {
    var cellConfig: CellConfig?

    var numberOfSections: Int {
        categoryProvider?.numberOfSections ?? 0
    }

    private(set) var selected: String?
    private let categoryProvider: CategoryProviderProtocol?

    init(categoryProvider: CategoryProviderProtocol?) {
        self.categoryProvider = categoryProvider
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        categoryProvider?.numberOfRowsInSection(section) ?? 0
    }

    func find(at indexPath: IndexPath) -> SettingsTableItem? {
        guard let category = categoryProvider?.find(at: indexPath),
              let title = category.title
        else { return nil }

        return CategoryCellModel(title: title, isSelected: selected == title)
    }

    func setSelectedCategory(_ selected: String?) {
        self.selected = selected
    }
}
