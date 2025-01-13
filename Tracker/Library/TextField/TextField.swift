import UIKit

final class TextField: UITextField {
    private var textPadding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 44)

    override init(frame: CGRect) {
        super.init(frame: frame)

        font = .systemFont(ofSize: 17)
        textColor = .Theme.contrast
        backgroundColor = .Theme.backgroundCard
        borderStyle = .none
        layer.cornerRadius = 16
        clearButtonMode = .whileEditing
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    private func setupConstraints() {
        guard let superview = self.superview else { return }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 75),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -16),
        ])
    }
}
