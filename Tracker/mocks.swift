import Foundation

let mockedTrackers: [Tracker] = [
    .init(id: .init(), title: "Поливать растения", color: .Tracker._3, emoji: "🌺", schedule: .init(selectedDays: [.monday, .friday])),
    .init(id: .init(), title: "Бабушка прислала открытку в вотсапе", color: .Tracker._1, emoji: "💌", schedule: .init(selectedDays: [.sunday])),
    .init(id: .init(), title: "Свидания в апреле", color: .Tracker._0, emoji: "❤️", schedule: .init(selectedDays: [.monday, .tuesday, .wednesday, .thursday, .friday])),
]

let mockedCategories: [Category] = [
    .init(title: "Домашний уют", trackers: [mockedTrackers[0]]),
    .init(title: "Радостные мелочи", trackers: [mockedTrackers[1], mockedTrackers[2]]),
]

let mockedCompletedTrackers: [Record] = [
    .init(trackerID: mockedTrackers[0].id, date: "06.01.25"),
    .init(trackerID: mockedTrackers[0].id, date: "10.01.25"),
    .init(trackerID: mockedTrackers[0].id, date: "16.01.25"),
    .init(trackerID: mockedTrackers[1].id, date: "12.01.25"),
    .init(trackerID: mockedTrackers[1].id, date: "19.01.25"),
    .init(trackerID: mockedTrackers[2].id, date: "06.01.25"),
    .init(trackerID: mockedTrackers[2].id, date: "08.01.25"),
    .init(trackerID: mockedTrackers[2].id, date: "14.01.25"),
    .init(trackerID: mockedTrackers[2].id, date: "15.01.25"),
]
