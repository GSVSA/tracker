import UIKit

protocol SettingsCellProtocol: UITableViewCell {
    static var reuseIdentifier: String { get }

    var delegate: SettingsCellDelegate? { get set }
    func setup(_ config: SettingsCellSetupModel)
}
