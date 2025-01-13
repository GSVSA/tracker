import Foundation

struct ValidationConfig {
    let required: Bool
    let maxLength: Int
}

struct ValidationErrorState {
    let required: String?
    let maxLength: String?
}
