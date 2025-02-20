import UIKit

final class CategoryViewController: UIViewController {
    var delegate: CategoryViewControllerDelegate?

    private var viewModel: CategoryViewModelProtocol?
    private var tableHeightConstraint: NSLayoutConstraint!

    private lazy var tableView = SettingsTable()

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
        setupViewModel()
        setupTableView()
        setupConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadHeightConstraints()
    }

    func initialize(viewModel: CategoryViewModelProtocol) {
        self.viewModel = viewModel
    }

    private func setupViewModel() {
        viewModel?.didNumberOfRowsUpdate = { [weak self] numberOfRows in
            self?.didNumberOfRowsUpdate(numberOfRows)
        }
        viewModel?.didUpdate = { [weak self] in
            self?.didUpdate()
        }
        viewModel?.navigateToEdition = { [weak self] indexPath, title in
            self?.navigateToEdition(at: indexPath, with: title)
        }
    }

    private func setupTableView() {
        guard let viewModel else { return }
        let tableProvider = CategoryTableProvider(viewModel: viewModel)
        tableView.configure(provider: tableProvider, cell: SettingsCell.self)
        tableView.delegate = self
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

    @objc
    private func didAddCategoryTapped() {
        navigateToEdition(at: nil, with: nil)
    }

    private func navigateToEdition(at indexPath: IndexPath?, with title: String?) {
        let viewController = NewCategoryViewController()
        viewController.delegate = self
        viewController.setCategoryTitle(title)
        viewController.setIndexPath(indexPath)
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }

    private func didUpdate() {
        tableView.reloadData()
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
        let category = viewModel?.selectCategory(at: indexPath)
        delegate?.didComplete(with: category?.title)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.viewModel?.edit(at: indexPath)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    self?.viewModel?.delete(at: indexPath)
                },
            ])
        })
    }
}

// MARK: - NewCategoryViewControllerDelegate

extension CategoryViewController: NewCategoryViewControllerDelegate {
    func didCreateNewCategory(withName name: String, at indexPath: IndexPath?) {
        viewModel?.addOrUpdate(name, at: indexPath)
        delegate?.didComplete(with: name)
    }
}
