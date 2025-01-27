import UIKit

class Button: UIButton {
    var isDisabled = false {
        didSet {
            isEnabled = !isDisabled
            applyStyle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        layer.cornerRadius = 16
        applyStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    private func applyStyle() {
        if !isDisabled {
            setTitleColor(.Theme.background, for: .normal)
            backgroundColor = .Theme.contrast
        } else {
            setTitleColor(.white, for: .normal)
            backgroundColor = .Theme.secondary
        }
    }
}
