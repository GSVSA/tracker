import UIKit

struct ColorsCollectionCellModel {
    let selected: Bool
    let color: UIColor
}

final class ColorsCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"

    private lazy var colorView: UIView = {
        let color = UIView()
        color.layer.cornerRadius = 8
        return color
    }()

    private var color: UIColor?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.borderWidth = 3
        contentView.layer.cornerRadius = 11
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0).cgColor

        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(_ info: ColorsCollectionCellModel) {
        setColor(info.color)
        setSelected(info.selected)
    }

    private func setColor(_ color: UIColor) {
        self.color = color
        colorView.backgroundColor = color
    }

    private func setSelected(_ selected: Bool) {
        contentView.layer.borderColor = selected
            ? color?.withAlphaComponent(0.3).cgColor
            : color?.withAlphaComponent(0).cgColor
    }

}

