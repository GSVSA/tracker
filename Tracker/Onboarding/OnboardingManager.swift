import Foundation

final class OnboardingManager {
    private let userDefaults = UserDefaults.standard
    private let onboardingKey = "onboardingWasHidden"

    var isCompleted: Bool {
        return userDefaults.bool(forKey: onboardingKey)
    }

    func complete() {
        userDefaults.set(true, forKey: onboardingKey)
        userDefaults.synchronize()
    }
}
