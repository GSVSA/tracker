import Foundation

protocol EventSettingsViewControllerDelegate {
    func didComplete(_ vc: EventSettingsViewController, tracker: TrackerProtocol, selectedDays: [Weekday], category: CategoryProtocol)
}
