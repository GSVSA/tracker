import UIKit

final class CategoryViewController: UIViewController {
    var delegate: CategoryViewControllerDelegate?

    private lazy var tableView = SettingsTable()
    private var tableHeightConstraint: NSLayoutConstraint!

    private lazy var categoryProvider: CategoryProviderProtocol? = {
        let store = TrackerCategoryStore()
        do {
            try categoryProvider = CategoryProvider(store)
            categoryProvider?.delegate = self
            return categoryProvider
        } catch {
            return nil
        }
    }()

    private lazy var tableProvider: CategoryTableProvider = {
        let provider = CategoryTableProvider(categoryProvider: categoryProvider)
        return provider
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
        setEmptyBlockVisible(tableProvider.numberOfSections == 0)
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

    @objc
    private func didAddCategoryTapped() {
        let viewController = NewCategoryViewController()
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }

    private func configureNavBar() {
        navigationItem.title = "Категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
    }

    private func setEmptyBlockVisible(_ isVisible: Bool) {
        emptyBlock.isHidden = !isVisible
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
        setSelectedCategory(category?.title)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.edit(indexPath: indexPath)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    self?.delete(indexPath: indexPath)
                },
            ])
        })
    }

    private func edit(indexPath: IndexPath) {
        guard let categoryTitle = tableProvider.find(at: indexPath)?.title else { return }

        let viewController = NewCategoryViewController()
        viewController.delegate = self
        viewController.setCategoryTitle(categoryTitle)
        viewController.setIndexPath(indexPath)
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }

    private func delete(indexPath: IndexPath) {
        categoryProvider?.deleteRecord(at: indexPath)
    }
}

// MARK: - NewCategoryViewControllerDelegate

extension CategoryViewController: NewCategoryViewControllerDelegate {
    func didCreateNewCategory(withName name: String, at indexPath: IndexPath?) {
        let newCategory = Category(title: name)
        guard let indexPath else {
            categoryProvider?.addRecord(newCategory)
            return
        }
        categoryProvider?.updateRecord(at: indexPath, newCategory)
    }
}

// MARK: - CategoryProviderDelegate

extension CategoryViewController: CategoryProviderDelegate {
    func didUpdate(_ update: CategoryStoreUpdate) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: Array(update.insertedIndexes), with: .automatic)
            tableView.reloadRows(at: Array(update.updatedIndexes), with: .automatic)
            tableView.deleteRows(at: Array(update.deletedIndexes), with: .fade)
        }
        reloadHeightConstraints()
    }
}
