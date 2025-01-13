import UIKit

struct SettingsCellSetupModel {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let indexPath: IndexPath
    let isSwitcher: Bool?
    let accessoryType: UITableViewCell.AccessoryType?
}

final class SettingsCell: UITableViewCell, SettingsCellProtocol {
    static let reuseIdentifier = "EventSettingsCell"

    var delegate: SettingsCellDelegate?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        backgroundColor = .Theme.backgroundCard
        selectionStyle = .none

        textLabel?.font = .systemFont(ofSize: 17)
        textLabel?.textColor = .Theme.contrast
        detailTextLabel?.font = .systemFont(ofSize: 17)
        detailTextLabel?.textColor = .Theme.secondary
    }

    func setup(_ config: SettingsCellSetupModel) {
        setTitle(config.title)
        setSubtitle(config.subtitle)

        accessoryType = config.isSelected
            ? .checkmark
            : (config.accessoryType ?? .none)

        if config.isSwitcher ?? false {
            let switcher = Switcher()
            switcher.isOn = config.isSelected
            switcher.didChangeValue = { [weak self] isOn in
                self?.delegate?.didChangeValue(switcher, for: config.indexPath, isOn: isOn)
            }
            accessoryView = switcher
        }
    }

    private func setTitle(_ title: String) {
        textLabel?.text = title
    }

    private func setSubtitle(_ subtitle: String?) {
        detailTextLabel?.text = subtitle
    }
}
