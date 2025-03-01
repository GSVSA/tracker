import UIKit

final class FiltersViewController: UIViewController {
    var didChangeValue: ((FilterType) -> Void)?

    private var viewModel: FiltersViewModelProtocol?

    private lazy var tableView = SettingsTable()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Theme.background
        configureNavBar()
        setupTableView()
        setupViewModel()
        setupConstraints()
    }

    func initialize(viewModel: FiltersViewModelProtocol) {
        self.viewModel = viewModel
    }

    private func setupViewModel() {
        viewModel?.didUpdate = { [weak self] in
            self?.didUpdate()
        }
    }

    private func setupTableView() {
        guard let viewModel else { return }
        tableView.configure(provider: viewModel, cell: SettingsCell.self)
        tableView.delegate = self
    }

    private func configureNavBar() {
        navigationItem.title = "Фильтры"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
    }

    private func didUpdate() {
        tableView.reloadData()
    }

    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -11),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.select(at: indexPath)
        guard let selected = viewModel?.selected else { return }
        didChangeValue?(selected)
        dismiss(animated: true)
    }
}
