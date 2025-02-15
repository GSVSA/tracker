import UIKit

final class CategoryViewController: UIViewController {
    var delegate: CategoryViewControllerDelegate?

    private lazy var tableView = SettingsTable()
    private var tableHeightConstraint: NSLayoutConstraint!

    private lazy var categoryProvider: CategoryProviderProtocol? = {
        let store = TrackerCategoryStore()
        do {
            try categoryProvider = CategoryProvider(store)
            categoryProvider?.didUpdate = didUpdate
            categoryProvider?.didNumberOfRowsUpdate = didNumberOfRowsUpdate
            return categoryProvider
        } catch {
            return nil
        }
    }()

    private lazy var tableProvider: CategoryTableProvider = {
        let tableProvider = CategoryTableProvider(categoryProvider: categoryProvider)
        tableProvider.navigateToEdition = navigateToEdition
        return tableProvider
    }()

    private lazy var emptyBlock: EmptyBlock = {
        let block = EmptyBlock()
        block.setLabel("Привычки и события можно\nобъединить по смыслу")
        return block
    }()

    private lazy var createCategoryButton: Button = {
        let button = Button()
        button.setTitle("Добавить категорию", for: .normal)
        button.addTarget(self, action: #selector(didAddCategoryTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Theme.background
        configureNavBar()
        tableView.configure(provider: tableProvider, cell: SettingsCell.self)
        tableView.delegate = self
        setupConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadHeightConstraints()
    }

    func setSelectedCategory(_ selected: String?) {
        tableProvider.setSelectedCategory(selected)
    }

    private func reloadHeightConstraints() {
        tableHeightConstraint.constant = tableView.contentSize.height
    }

    private func configureNavBar() {
        navigationItem.title = "Категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
    }

    private func navigateToEdition(indexPath: IndexPath?, categoryTitle: String?) {
        let viewController = NewCategoryViewController()
        viewController.delegate = self
        viewController.setCategoryTitle(categoryTitle)
        viewController.setIndexPath(indexPath)
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }

    @objc
    private func didAddCategoryTapped() {
        navigateToEdition(indexPath: nil, categoryTitle: nil)
    }

    private func didUpdate(_ update: CategoryStoreUpdate) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: Array(update.insertedIndexes), with: .automatic)
            tableView.reloadRows(at: Array(update.updatedIndexes), with: .automatic)
            tableView.deleteRows(at: Array(update.deletedIndexes), with: .fade)
        }
        reloadHeightConstraints()
    }

    private func didNumberOfRowsUpdate(_ numberOfRows: Int) {
        emptyBlock.isHidden = numberOfRows != 0
    }

    private func setupConstraints() {
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint.isActive = true

        [
            emptyBlock,
            tableView,
            createCategoryButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -11),

            emptyBlock.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor),
        ])
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = tableProvider.find(at: indexPath)
        delegate?.didComplete(with: category?.title)
        tableProvider.setSelectedCategory(category?.title)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.tableProvider.edit(indexPath: indexPath)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    self?.tableProvider.delete(indexPath: indexPath)
                },
            ])
        })
    }
}

// MARK: - NewCategoryViewControllerDelegate

extension CategoryViewController: NewCategoryViewControllerDelegate {
    func didCreateNewCategory(withName name: String, at indexPath: IndexPath?) {
        tableProvider.addOrUpdateRecord(withName: name, at: indexPath)
    }
}
