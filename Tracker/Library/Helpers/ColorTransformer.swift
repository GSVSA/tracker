import UIKit

@objc
final class ColorTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }

    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
        } catch {
            print("Ошибка кодирования UIColor: \(error)")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
        } catch {
            print("Ошибка декодирования UIColor: \(error)")
            return nil
        }
    }

    static func register() {
        ValueTransformer.setValueTransformer(
            ColorTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: ColorTransformer.self))
        )
    }
}
