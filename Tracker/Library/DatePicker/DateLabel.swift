import UIKit

final class DateLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 6, left: 5.5, bottom: 6, right: 5.5) {
        didSet {
            setNeedsDisplay()
        }
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let width = size.width + textInsets.left + textInsets.right
        let height = size.height + textInsets.top + textInsets.bottom
        return CGSize(width: width, height: height)
    }

    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittingSize = super.sizeThatFits(size)
        let width = fittingSize.width + textInsets.left + textInsets.right
        let height = fittingSize.height + textInsets.top + textInsets.bottom
        return CGSize(width: width, height: height)
    }

    func update(with date: Date) {
        text = dateFormatter.string(from: date)
    }

    private func setupLabel() {
        textAlignment = .center
        textColor = ThemeManager.isLightMode
            ? .Theme.contrast
            : .Theme.background
        backgroundColor = .Theme.datePickerLabel
        layer.cornerRadius = 8
        layer.masksToBounds = true
        font = UIFont.systemFont(ofSize: 17)
    }
}
