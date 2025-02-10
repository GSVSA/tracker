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

protocol SettingsTableProvider {
    var cellConfig: CellConfig? { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func find(at: IndexPath) -> SettingsTableItem?
}

final class SettingsTable: UITableView {
    weak var settingsCellDelegate: SettingsCellDelegate?

    private var reuseIdentifier: String = "SettingsCell"
    private var cell: SettingsCellProtocol?
    private var provider: SettingsTableProvider?

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

    func configure(provider: SettingsTableProvider, cell: SettingsCellProtocol.Type, reuseIdentifier: String? = nil) {
        self.provider = provider
        self.reuseIdentifier = reuseIdentifier ?? cell.reuseIdentifier
        register(cell, forCellReuseIdentifier: reuseIdentifier ?? cell.reuseIdentifier)
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

// MARK: - UITableViewDataSource

extension SettingsTable: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        provider?.numberOfSections ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        provider?.numberOfRowsInSection(section) ?? 0
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
        cell.delegate = settingsCellDelegate
        guard let cellInfo = provider?.find(at: indexPath) else { return }
        cell.setup(.init(
            title: cellInfo.title,
            subtitle: cellInfo.subtitle,
            isSelected: cellInfo.isSelected ?? false,
            indexPath: indexPath,
            isSwitcher: provider?.cellConfig?.isSwitcher,
            accessoryType: provider?.cellConfig?.accessoryType
        ))
    }
}
