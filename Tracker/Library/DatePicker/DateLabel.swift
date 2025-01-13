import UIKit

final class DateLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 6, left: 5.5, bottom: 6, right: 5.5) {
        didSet {
            setNeedsDisplay()
        }
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

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let width = size.width + textInsets.left + textInsets.right
        let height = size.height + textInsets.top + textInsets.bottom
        return CGSize(width: width, height: height)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittingSize = super.sizeThatFits(size)
        let width = fittingSize.width + textInsets.left + textInsets.right
        let height = fittingSize.height + textInsets.top + textInsets.bottom
        return CGSize(width: width, height: height)
    }

    func update(with date: Date) {
        self.text = dateFormatter.string(from: date)
    }

    private func setupLabel() {
        self.textAlignment = .center
        let currentTheme = UIScreen.main.traitCollection.userInterfaceStyle
        self.textColor = currentTheme == .light
            ? .Theme.contrast
            : .Theme.background
        self.backgroundColor = .Theme.datePickerLabel
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.font = UIFont.systemFont(ofSize: 17)
    }
}
