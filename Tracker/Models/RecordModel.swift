import Foundation

protocol RecordProtocol {
    var date: String { get }
}

struct Record: RecordProtocol {
    let date: String
}
