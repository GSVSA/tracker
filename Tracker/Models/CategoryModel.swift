import Foundation

protocol CategoryProtocol {
    var title: String { get }
}

struct Category: CategoryProtocol {
    let title: String
}
