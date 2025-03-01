import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
    func testTrackersViewController_LightMode() {
        let viewController = TabBarController()
        withSnapshotTesting(diffTool: .ksdiff) {
            assertSnapshot(of: viewController, as: .image(traits: .init(userInterfaceStyle: .light)))
        }
    }

    func testTrackersViewController_DarkMode() {
        let viewController = TabBarController()
        withSnapshotTesting(diffTool: .ksdiff) {
            assertSnapshot(of: viewController, as: .image(traits: .init(userInterfaceStyle: .dark)))
        }
    }
}
