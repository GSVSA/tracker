import UIKit

final class NewCategoryViewController: UIViewController {
    private lazy var nameInput: UIView = {
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

    @objc
    private func didDoneTapped() {
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

// MARK: - extensions

extension NewCategoryViewController: ValidationTextFieldWrapperDelegate {
    func textFieldShouldReturn(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func onError(_ hasError: Bool) {
        doneButton.isDisabled = hasError
    }
}
