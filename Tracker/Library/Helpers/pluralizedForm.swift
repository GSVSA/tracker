import Foundation

func pluralize(for number: Int, forms: (String, String, String)) -> String {
    let mod100 = number % 100
    let mod10 = number % 10

    if mod100 >= 11 && mod100 <= 19 {
        return forms.2
    }

    switch mod10 {
    case 1:
        return forms.0
    case 2...4:
        return forms.1
    default:
        return forms.2
    }
}
