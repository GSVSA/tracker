import UIKit

final class StatisticViewController: UIViewController {
    private lazy var emptyBlock: EmptyBlock = {
        let block = EmptyBlock()
        block.setImage(UIImage(named: "StatisticEmpty"))
        block.setLabel("Анализировать пока нечего")
        return block
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavBar()
        setupConstraints()
    }
    
    func configureNavBar() {
        navigationItem.title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupConstraints() {
        emptyBlock.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyBlock)

        NSLayoutConstraint.activate([
            emptyBlock.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

