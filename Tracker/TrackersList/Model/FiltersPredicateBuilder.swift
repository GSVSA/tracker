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
            return NSCompoundPredicate(type: .or, subpredicates: [isIrregular, isCurrentDate])
        }
    }
}
