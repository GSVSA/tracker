import Foundation

protocol ScheduleViewControllerDelegate: AnyObject {
    func didComplete(with schedule: [Weekday])
}
