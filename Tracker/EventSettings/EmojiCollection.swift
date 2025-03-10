import UIKit

protocol EmojiCollectionDelegate: AnyObject {
    func emojiCollection(_ collection: EmojiCollection, didSelectEmoji emoji: String?)
}

final class EmojiCollection: UICollectionView {
    var selectedEmoji: String?

    weak var selectionDelegate: EmojiCollectionDelegate?

    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪",
    ]

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        backgroundColor = .none

        register(EmojiCollectionCell.self, forCellWithReuseIdentifier: EmojiCollectionCell.reuseIdentifier)
        register(CollectionHeader.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: CollectionHeader.reuseIdentifier)
        dataSource = self
        delegate = self
        allowsMultipleSelection = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EmojiCollection: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // размеры для каждой ячейки
        let width = collectionView.bounds.width / 6
        return CGSize(width: width, height: width)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        // минимальный отступ между строками коллекции
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        // минимальный отступ между ячейками
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 46)
    }
}

// MARK: - UICollectionViewDataSource

extension EmojiCollection: UICollectionViewDataSource {
    // количество ячеек в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt: IndexPath) -> UICollectionViewCell {
        // сама ячейка
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionCell.reuseIdentifier, for: cellForItemAt)
        guard let emojiCollectionCell = cell as? EmojiCollectionCell else {
            return UICollectionViewCell()
        }
        configCell(emojiCollectionCell, for: cellForItemAt)
        return emojiCollectionCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader {
            return UICollectionReusableView()
        }

        guard
            let collectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: CollectionHeader.reuseIdentifier,
                                                                                   for: indexPath) as? CollectionHeader
        else {
            return UICollectionReusableView()
        }
        collectionHeader.setLabel("Emoji")
        return collectionHeader
    }

    private func configCell(_ cell: EmojiCollectionCell, for indexPath: IndexPath) {
        let emoji = emojis[indexPath.item]
        let isSelected = emoji == selectedEmoji
        cell.setup(.init(selected: isSelected, emoji: emoji))
    }
}

// MARK: - UICollectionViewDelegate

extension EmojiCollection: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEmoji = emojis[indexPath.item]
        collectionView.reloadData()
        selectionDelegate?.emojiCollection(self, didSelectEmoji: selectedEmoji)
    }
}
