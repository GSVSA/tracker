import Foundation

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
        categoryViewModel.numberOfSections
    }

    private let categoryViewModel: CategoryViewModelProtocol

    init(viewModel: CategoryViewModelProtocol) {
        self.categoryViewModel = viewModel
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        categoryViewModel.numberOfRowsInSection(section)
    }

    func find(at indexPath: IndexPath) -> SettingsTableItem? {
        guard let title = categoryViewModel.find(at: indexPath)?.title else { return nil }
        return CategoryCellModel(title: title, isSelected: categoryViewModel.selected == title)
    }
}
