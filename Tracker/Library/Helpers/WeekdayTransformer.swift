import Foundation

@objc
final class WeekdayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }

    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [String] else { return nil }
        do {
            return try JSONEncoder().encode(days)
        } catch {
            print("Ошибка кодирования Weekday: \(error)")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            return try JSONDecoder().decode([String].self, from: data)
        } catch {
            print("Ошибка декодирования Weekday: \(error)")
            return nil
        }
    }

    static func register() {
        ValueTransformer.setValueTransformer(
            WeekdayTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: WeekdayTransformer.self))
        )
    }
}
