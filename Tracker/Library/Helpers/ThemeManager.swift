import UIKit

final class ThemeManager {
    static var currentTheme: UIUserInterfaceStyle {
        UIScreen.main.traitCollection.userInterfaceStyle
    }

    static var isLightMode: Bool {
        currentTheme == .light
    }
}
