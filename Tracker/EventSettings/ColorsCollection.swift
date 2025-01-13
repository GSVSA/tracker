import UIKit

final class ColorsCollection: UICollectionView {
    private let colors: [UIColor] = [
        .Tracker._0, .Tracker._1, .Tracker._2,
        .Tracker._3, .Tracker._4, .Tracker._5,
        .Tracker._6, .Tracker._7, .Tracker._8,
        .Tracker._9, .Tracker._10, .Tracker._11,
        .Tracker._12, .Tracker._13, .Tracker._14,
        .Tracker._15, .Tracker._16, .Tracker._17
    ]
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        backgroundColor = .none
        
        register(ColorsCollectionCell.self, forCellWithReuseIdentifier: ColorsCollectionCell.reuseIdentifier)
        register(CollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeader.reuseIdentifier)
        dataSource = self
        delegate = self
        allowsMultipleSelection = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - extensions

extension ColorsCollection: UICollectionViewDelegateFlowLayout {
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

extension ColorsCollection: UICollectionViewDataSource {
    // количество ячеек в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt: IndexPath) -> UICollectionViewCell {
        // сама ячейка
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionCell.reuseIdentifier, for: cellForItemAt)
        guard let colorsCollectionCell = cell as? ColorsCollectionCell else {
            return UICollectionViewCell()
        }
        configCell(colorsCollectionCell, for: cellForItemAt)
        return colorsCollectionCell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader {
            return UICollectionReusableView()
        }

        guard
            let collectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeader.reuseIdentifier, for: indexPath) as? CollectionHeader
        else {
            return UICollectionReusableView()
        }
        collectionHeader.setLabel("Цвет")
        return collectionHeader
    }

    private func configCell(_ cell: ColorsCollectionCell, for indexPath: IndexPath) {
        let color = colors[indexPath.item]
        cell.setColor(color)
    }
}

extension ColorsCollection: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionCell
        cell?.setSelected(true)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionCell
        cell?.setSelected(false)
    }
}

