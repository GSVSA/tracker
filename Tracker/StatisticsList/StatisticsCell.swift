import UIKit

struct StatisticsCellModel {
    let description: String
    let value: String
}

final class StatisticsCell: UICollectionViewCell {
    static let reuseIdentifier = "StatisticsCell"

    private let gradientLayer = CAGradientLayer()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .Theme.contrast
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .Theme.contrast
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.backgroundColor = .Theme.background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        setupConstraints()
        setupGradient()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }

    func setup(_ info: StatisticsCellModel) {
        setValue(info.value)
        setDescription(info.description)
    }

    private func setValue(_ value: String) {
        valueLabel.text = value
    }

    private func setDescription(_ description: String) {
        descriptionLabel.text = description
    }

    private func setupGradient() {
        // Цвета градиента: #007BFA -> #46E69D -> #FD4C49
        gradientLayer.colors = [
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0.0, 0.53, 1.0]

        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 0.0, y: 0.5)
    }

    private func setupConstraints() {
        contentView.layer.insertSublayer(gradientLayer, at: 0)
        contentView.addSubview(containerView)
        [
            valueLabel,
            descriptionLabel,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),

            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            descriptionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
        ])
    }
}
