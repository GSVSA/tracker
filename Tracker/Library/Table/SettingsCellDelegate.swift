import Foundation

protocol SettingsCellDelegate: AnyObject {
    func didChangeValue(_ sender: UISwitch, for indexPath: IndexPath, isOn: Bool)
}
