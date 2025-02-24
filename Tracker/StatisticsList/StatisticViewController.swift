import UIKit

final class StatisticViewController: UIViewController {
    private var viewModel: StatisticsViewModelProtocol?

    private lazy var statisticsCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private lazy var emptyBlock: EmptyBlock = {
        let block = EmptyBlock()
        block.setImage(UIImage(named: "StatisticEmpty"))
        block.setLabel(NSLocalizedString("statisticsEmptyState", comment: "Текст отображаемый при отсутствии статистики на странице"))
        return block
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Theme.background
        configureNavBar()
        setupCollection()
        setupViewModel()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        statisticsCollection.reloadData()
    }

    func initialize(viewModel: StatisticsViewModelProtocol) {
        self.viewModel = viewModel
    }

    private func setupViewModel() {
        viewModel?.didNumberOfRowsUpdate = { [weak self] numberOfRows in
            self?.didNumberOfRowsUpdate(numberOfRows)
        }
    }

    private func setupCollection() {
        statisticsCollection.register(StatisticsCell.self, forCellWithReuseIdentifier: StatisticsCell.reuseIdentifier)
        statisticsCollection.backgroundColor = .Theme.background
        statisticsCollection.dataSource = self
        statisticsCollection.delegate = self
    }

    private func didNumberOfRowsUpdate(_ numberOfRows: Int) {
        emptyBlock.isHidden = numberOfRows != 0
    }

    private func configureNavBar() {
        navigationItem.title = NSLocalizedString("statisticsTitle", comment: "Заголовок страницы")
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupConstraints() {
        [
            emptyBlock,
            statisticsCollection,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            emptyBlock.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            statisticsCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 69),
            statisticsCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            statisticsCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticsCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}

extension StatisticViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 90)
    }
}

extension StatisticViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.numberOfSections ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.numberOfRowsInSection(section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = statisticsCollection.dequeueReusableCell(withReuseIdentifier: StatisticsCell.reuseIdentifier, for: indexPath)
        guard let statisticsCell = cell as? StatisticsCell,
              let config = viewModel?.configureCell(forRowAt: indexPath)
        else {
            return UICollectionViewCell()
        }
        statisticsCell.setup(config)
        return statisticsCell
    }
}
