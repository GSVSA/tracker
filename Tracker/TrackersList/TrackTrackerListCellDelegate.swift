import Foundation

protocol TrackTrackerListCellDelegate: AnyObject {
    func didTapCounter(id trackerId: UUID)
}
