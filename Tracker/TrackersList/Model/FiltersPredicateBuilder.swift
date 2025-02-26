import Foundation

final class FiltersPredicateBuilder {
    private let filters: Filters?

    private let filterDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()

    private let scheduleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_EN")
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    var predicate: NSPredicate? {
        guard let filters = filters else { return nil }
        return build(filters: filters)
    }

    init(filters: Filters? = nil) {
        self.filters = filters
    }

    func build(filters: Filters) -> NSPredicate? {
        guard let date = filters.date else { return nil }
        let trackerType = filters.type

        let dateString = filterDateFormatter.string(from: date)

        switch trackerType {
        case .completed:
            return NSPredicate(
                format: "ANY %K.%K == %@",
                #keyPath(TrackerCoreData.records), #keyPath(RecordCoreData.date), dateString
            )
        case .notCompleted:
            return NSPredicate(
                format: "%K.@count == 0 OR NONE %K.%K == %@",
                #keyPath(TrackerCoreData.records),
                #keyPath(TrackerCoreData.records), #keyPath(RecordCoreData.date), dateString
            )
        case .all, .today:
            let weekdayName = scheduleDateFormatter.string(from: date).lowercased()
            let isCurrentDate = NSPredicate(
                format: "%K CONTAINS %@",
                #keyPath(TrackerCoreData.schedule.selectedDays), weekdayName
            )
            let isIrregular = NSPredicate(
                format: "%K == nil",
                #keyPath(TrackerCoreData.schedule.selectedDays)
            )
            return or([isIrregular, isCurrentDate])
        }
    }

    func build(filters: Filters, search: String? = nil, withPinned: Bool) -> NSPredicate? {
        guard let predicate = build(filters: filters) else { return nil }

        guard let search else {
            return and(subpredicates: [predicate, pinned(withPinned)])
        }

        return and(subpredicates: [predicate, pinned(withPinned), searched(search)])
    }

    func searched(_ text: String) -> NSPredicate {
        let lowercasedText = text.lowercased()
        return NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.title), lowercasedText
        )
    }

    func pinned(_ state: Bool = true) -> NSPredicate {
        return NSPredicate(format: "%K == \(state)", #keyPath(TrackerCoreData.pinned))
    }

    func and(subpredicates: [NSPredicate]) -> NSPredicate {
        return NSCompoundPredicate(type: .and, subpredicates: subpredicates)
    }

    func or(_ subpredicates: [NSPredicate]) -> NSPredicate {
        return NSCompoundPredicate(type: .or, subpredicates: subpredicates)
    }

    func not(_ subpredicates: [NSPredicate]) -> NSPredicate {
        return NSCompoundPredicate(type: .not, subpredicates: subpredicates)
    }
}
