import UIKit

struct TrackersListCellModel {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let count: Int
    let completed: Bool
    let disabled: Bool
    let pinned: Bool
}

final class TrackersListCell: UICollectionViewCell {
    static let reuseIdentifier = "cell"

    var delegate: TrackTrackerListCellDelegate?

    private var id: UUID?

    private lazy var containerBody: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.textAlignment = .center
        return label
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .Theme.contrast
        return label
    }()

    private lazy var pinIcon: UIImageView = {
        let image = UIImage(systemName: "pin.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = ThemeManager.themed(light: .Theme.background, dark: .Theme.contrast)
        return imageView
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus")
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .small)
        button.addTarget(self, action: #selector(didTapCounter), for: .touchUpInside)
        button.setPreferredSymbolConfiguration(imageConfiguration, forImageIn: .normal)
        button.setImage(image, for: .normal)
        button.tintColor = .Theme.background
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 17
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(_ info: TrackersListCellModel) {
        setId(info.id)
        setColor(info.color)
        setEmoji(info.emoji)
        setTitle(info.title)
        setCounter(info.count)
        setCompleted(info.completed)
        setButtonDisabled(info.disabled)
        setPinned(info.pinned)
    }

    private func setColor(_ color: UIColor) {
        containerBody.backgroundColor = color
        addButton.backgroundColor = color
    }
    
    private func setEmoji(_ emoji: String) {
        emojiLabel.text = emoji
    }
    
    private func setTitle(_ title: String) {
        titleLabel.text = title
    }

    private func setId(_ id: UUID) {
        self.id = id
    }

    private func setCounter(_ schedule: Int) {
        let localizedString = NSLocalizedString("countDays", comment: "Количество дней отображаемое в трекере")
        counterLabel.text = String(format: localizedString, schedule)
    }
    
    private func setCompleted(_ completed: Bool) {
        let defaultImage = UIImage(systemName: "plus")
        let completedImage = UIImage(systemName: "checkmark")
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: completed ? .bold : .medium, scale: .small)
        addButton.setImage(completed ? completedImage : defaultImage, for: .normal)
        addButton.setPreferredSymbolConfiguration(imageConfiguration, forImageIn: .normal)
        addButton.layer.opacity = completed ? 0.3 : 1
    }

    private func setButtonDisabled(_ disabled: Bool) {
        addButton.isEnabled = !disabled
    }

    private func setPinned(_ pinned: Bool) {
        pinIcon.isHidden = !pinned
    }
    
    private func setupConstraints() {
        [
            containerBody,
            titleLabel,
            emojiLabel,
            pinIcon,
            counterLabel,
            addButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerBody.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerBody.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerBody.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerBody.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            containerBody.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: containerBody.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: containerBody.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),

            pinIcon.topAnchor.constraint(equalTo: containerBody.topAnchor, constant: 18),
            pinIcon.trailingAnchor.constraint(equalTo: containerBody.trailingAnchor, constant: -12),
            pinIcon.widthAnchor.constraint(equalToConstant: 12),
            pinIcon.heightAnchor.constraint(equalToConstant: 12),

            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerBody.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: containerBody.bottomAnchor, constant: -12),
            
            counterLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            counterLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
            counterLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8),
            
            addButton.topAnchor.constraint(equalTo: containerBody.bottomAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34),            
        ])
    }

    @objc
    private func didTapCounter() {
        guard let id else { return }
        delegate?.didTapCounter(at: id)
    }
}

