import Foundation

struct FiltersCellModel: SettingsTableItem {
    let title: String
    let subtitle: String?
    let isSelected: Bool?

    init(title: String, isSelected: Bool? = false) {
        self.title = title
        self.subtitle = nil
        self.isSelected = isSelected
    }
}

protocol FiltersViewModelProtocol: SettingsTableProvider {
    var didUpdate: (() -> Void)? { get set }
    var selected: FilterType? { get }

    func select(_ filterType: FilterType)
    func select(at indexPath: IndexPath)
}

final class FiltersViewModel: FiltersViewModelProtocol {
    var didUpdate: (() -> Void)?

    var selected: FilterType? {
        filtersModel.type
    }

    private let filtersModel: FiltersModelProtocol

    init(model: FiltersModelProtocol) {
        self.filtersModel = model
    }

    func select(_ filterType: FilterType) {
        filtersModel.setType(filterType)
        didUpdate?()
    }

    func select(at indexPath: IndexPath) {
        let filterType = FilterType.allCases[indexPath.item]
        select(filterType)
    }
}

extension FiltersViewModel: SettingsTableProvider {
    var cellConfig: CellConfig? { nil }

    var numberOfSections: Int { 1 }

    func numberOfRowsInSection(_ section: Int) -> Int { FilterType.allCases.count }

    func find(at indexPath: IndexPath) -> SettingsTableItem? {
        let filterType = FilterType.allCases[indexPath.item]
        return FiltersCellModel(title: filterType.translated, isSelected: selected == filterType)
    }
}
