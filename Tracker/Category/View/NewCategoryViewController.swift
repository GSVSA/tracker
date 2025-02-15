import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didCreateNewCategory(withName name: String, at indexPath: IndexPath?)
}

final class NewCategoryViewController: UIViewController {
    weak var delegate: NewCategoryViewControllerDelegate?

    private var categoryTitle: String?
    private var indexPath: IndexPath?

    private lazy var nameInput: ValidationTextFieldWrapper = {
        let textField = TextField()
        textField.placeholder = "Введите название категории"
        let errorWrapper = ValidationTextFieldWrapper(textField)
        errorWrapper.delegate = self
        return errorWrapper
    }()
    
    private lazy var doneButton: Button = {
        let button = Button()
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(didDoneTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Theme.background
        setupConstraints()
        doneButton.isDisabled = true

        navigationItem.title = "Новая категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
    }

    func setCategoryTitle(_ title: String?) {
        categoryTitle = title
    }

    func setIndexPath(_ indexPath: IndexPath?) {
        self.indexPath = indexPath
    }

    @objc
    private func didDoneTapped() {
        guard let categoryTitle = nameInput.textField?.text else { return }
        delegate?.didCreateNewCategory(withName: categoryTitle, at: indexPath)
        setCategoryTitle(categoryTitle)
        dismiss(animated: true)
    }

    private func setupConstraints() {
        [
            nameInput,
            doneButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            nameInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),

            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - ValidationTextFieldWrapperDelegate

extension NewCategoryViewController: ValidationTextFieldWrapperDelegate {
    func textFieldShouldReturn(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func onError(_ hasError: Bool) {
        doneButton.isDisabled = hasError
    }
}
