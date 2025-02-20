import Foundation

protocol CategoryViewModelProtocol {
    var didUpdate: (() -> Void)? { get set }
    var didNumberOfRowsUpdate: Binding<Int>? { get set }
    var navigateToEdition: ((IndexPath, String) -> Void)? { get set }
    var selected: String? { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func selectCategory(_ selected: String?)
    func selectCategory(at indexPath: IndexPath) -> CategoryProtocol?
    func find(at: IndexPath) -> CategoryProtocol?
    func addOrUpdate(_ name: String, at indexPath: IndexPath?)
    func delete(at indexPath: IndexPath)
    func edit(at indexPath: IndexPath)
}

final class CategoryViewModel: CategoryViewModelProtocol {
    var didUpdate: (() -> Void)?
    var didNumberOfRowsUpdate: Binding<Int>?
    var navigateToEdition: ((IndexPath, String) -> Void)?

    private(set) var selected: String?

    private lazy var model = TrackerCategoryStore()

    var numberOfSections: Int { 1 }

    func numberOfRowsInSection(_: Int) -> Int {
        let numberOfRows = model.count
        didNumberOfRowsUpdate?(numberOfRows)
        return numberOfRows
    }

    func find(at indexPath: IndexPath) -> CategoryProtocol? {
        guard let category = model.find(at: indexPath.item),
              let title = category.title
        else { return nil }

        return Category(title: title)
    }

    func selectCategory(_ title: String?) {
        selected = title
    }

    func selectCategory(at indexPath: IndexPath) -> CategoryProtocol? {
        let category = find(at: indexPath)
        selectCategory(category?.title)
        return category
    }

    func addOrUpdate(_ name: String, at indexPath: IndexPath?) {
        selectCategory(name)
        model.addOrUpdate(Category(title: name), at: indexPath?.item)
        didUpdate?()
    }

    func delete(at indexPath: IndexPath) {
        guard let categoryTitle = find(at: indexPath)?.title else { return }
        if categoryTitle == selected {
            selectCategory(nil)
        }
        model.delete(at: indexPath.item)
        didUpdate?()
    }

    func edit(at indexPath: IndexPath) {
        guard let categoryTitle = find(at: indexPath)?.title else { return }
        navigateToEdition?(indexPath, categoryTitle)
    }
}
