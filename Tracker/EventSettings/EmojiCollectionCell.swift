import UIKit

struct EmojiCollectionCellModel {
    let selected: Bool
    let emoji: String
}

final class EmojiCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textColor = .Theme.contrast
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
       
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(_ info: EmojiCollectionCellModel) {
        setLabel(info.emoji)
        setSelected(info.selected)
    }

    private func setLabel(_ text: String) {
        label.text = text
    }

    private func setSelected(_ selected: Bool) {
        contentView.backgroundColor = selected ? .Theme.selection : .none
    }
}

