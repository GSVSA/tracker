import UIKit

struct CellConfig {
    let accessoryType: UITableViewCell.AccessoryType
    let isSwitcher: Bool?

    init(accessoryType: UITableViewCell.AccessoryType = .none, accessoryView: UIView? = nil, isSwitcher: Bool? = nil) {
        self.accessoryType = accessoryType
        self.isSwitcher = isSwitcher
    }
}

protocol SettingsTableItem {
    var title: String { get }
    var subtitle: String? { get }
    var isSelected: Bool? { get }
}

final class SettingsTable: UITableView {
    weak var settingsCellDelegate: SettingsCellDelegate?

    private var reuseIdentifier: String = "SettingsCell"
    private var cell: SettingsCellProtocol?
    private var items: [SettingsTableItem] = []
    private var cellConfig: CellConfig?

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .insetGrouped)

        backgroundColor = .none
        dataSource = self
        rowHeight = 75
        separatorStyle = .singleLine
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        separatorColor = .Theme.secondary
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func didMoveToSuperview() {
        setupConstraints()
    }

    func configure(items: [SettingsTableItem], cell: SettingsCellProtocol.Type, reuseIdentifier: String? = nil) {
        self.items = items
        self.reuseIdentifier = reuseIdentifier ?? cell.reuseIdentifier
        register(cell, forCellReuseIdentifier: reuseIdentifier ?? cell.reuseIdentifier)
    }

    func updateItems(_ items: [SettingsTableItem]) {
        self.items = items
        reloadData()
    }

    func setCellConfig(_ config: CellConfig) {
        cellConfig = config
    }

    private func setupConstraints() {
        guard let superview = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: -4),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 4),
        ])
    }
}

// MARK: - extensions

extension SettingsTable: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
        guard let eventSettingsCell = cell as? SettingsCellProtocol else {
            return UITableViewCell()
        }
        configCell(for: eventSettingsCell, with: indexPath)
        return eventSettingsCell
    }

    private func configCell(for cell: SettingsCellProtocol, with indexPath: IndexPath) {
        let cellInfo = items[indexPath.row]
        cell.delegate = settingsCellDelegate
        cell.setup(.init(
            title: cellInfo.title,
            subtitle: cellInfo.subtitle,
            isSelected: cellInfo.isSelected ?? false,
            indexPath: indexPath,
            isSwitcher: cellConfig?.isSwitcher,
            accessoryType: cellConfig?.accessoryType
        ))
    }
}
