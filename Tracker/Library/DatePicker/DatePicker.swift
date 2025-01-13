import UIKit

final class DatePicker: UIDatePicker {
    private lazy var dateLabel: DateLabel = {
        let label = DateLabel()
        label.update(with: self.date)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        setupConstraints()
    }

    private func setupActions() {
        addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }

    @objc
    private func datePickerChanged(_ sender: UIDatePicker) {
        dateLabel.update(with: sender.date)
    }

    private func setupConstraints() {
        guard let superview else { return }
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}
