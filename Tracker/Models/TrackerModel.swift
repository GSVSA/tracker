import UIKit

protocol TrackerProtocol {
    var title: String { get }
    var color: UIColor { get }
    var emoji: String { get }
    var pinned: Bool? { get }
}

struct Tracker: TrackerProtocol {
    let title: String
    let color: UIColor
    let emoji: String
    let pinned: Bool?
}
