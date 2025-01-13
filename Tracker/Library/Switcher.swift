import UIKit

final class Switcher: UISwitch {
    var didChangeValue: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        onTintColor = .Theme.accent
        addTarget(self, action: #selector(onChangeValue), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onChangeValue(_ switcher: UISwitch) {
        didChangeValue?(switcher.isOn)
    }
}
