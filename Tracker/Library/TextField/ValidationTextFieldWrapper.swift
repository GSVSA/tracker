import UIKit

struct ValidationErrorMessages {
    static let required = "Обязательное поле"
    static let maxLength = "Ограничение 38 символов"
}

protocol ValidationTextFieldWrapperDelegate {
    func textFieldShouldReturn(_ textField: UITextField)
    func onError(_ hasError: Bool)
}

final class ValidationTextFieldWrapper: UIView {
    var delegate: ValidationTextFieldWrapperDelegate?

    private(set) var textField: UITextField?

    var validation: ValidationConfig = .init(required: true, maxLength: 38)
    private(set) var hasError = true

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Theme.danger
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        return label
    }()

    init(_ textField: UITextField) {
        super.init(frame: .zero)
        textField.delegate = self
        textField.addTarget(self, action: #selector(didValueChanged), for: .editingChanged)
        self.textField = textField
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        setupConstraints()
    }

    private func setupConstraints() {
        guard
            let superview = self.superview,
            let textField = self.textField
        else { return }

        [
            errorLabel,
            textField,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),

            textField.topAnchor.constraint(equalTo: topAnchor),
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: textField.centerXAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func validate(_ value: String) -> String? {
        let state = ValidationErrorState(
            required: validation.required && value.isEmpty ? ValidationErrorMessages.required : nil,
            maxLength: value.count > validation.maxLength ? ValidationErrorMessages.maxLength : nil
        )

        return state.required ?? state.maxLength
    }

    private func updateErrorState(_ error: String?) {
        let hasError = error != nil

        errorLabel.isHidden = !hasError
        errorLabel.text = error
        if self.hasError != hasError {
            self.hasError = hasError
            delegate?.onError(hasError)
        }
    }

    @objc
    private func didValueChanged(_ sender: UITextField) {
        updateErrorState(validate(sender.text ?? ""))
    }
}

// MARK: - extensions

extension ValidationTextFieldWrapper: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        updateErrorState(validate(""))
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn(textField)
        textField.resignFirstResponder()
        return true
    }
}
