import UIKit

final class ThemeManager {
    static var currentTheme: UIUserInterfaceStyle {
        UIScreen.main.traitCollection.userInterfaceStyle
    }

    static var isLightMode: Bool {
        currentTheme == .light
    }

    static func themed(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { (traits: UITraitCollection) -> UIColor in
            if traits.userInterfaceStyle == .light {
                return light
            } else {
                return dark
            }
        }
    }
}
