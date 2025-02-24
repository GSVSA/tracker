import Foundation

protocol StatisticsViewModelProtocol {
    var didNumberOfRowsUpdate: Binding<Int>? { get set }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func configureCell(forRowAt indexPath: IndexPath) -> StatisticsCellModel
}

struct StatisticsItem {
    let description: String
    let getStatistics: () -> String
}

final class StatisticsViewModel: StatisticsViewModelProtocol {
    var didNumberOfRowsUpdate: Binding<Int>?

    var statisticsData: [StatisticsItem] = []

    private lazy var recordsModel = TrackerRecordStore()
    private lazy var trackersModel = TrackerStore()

    var numberOfSections: Int { 1 }

    init() {
        statisticsData = [
            .init(description: "Трекеров завершено", getStatistics: getCompletedTrackersCount)
        ]
    }

    func numberOfRowsInSection(_: Int) -> Int {
        let numberOfRows = statisticsData.count
        didNumberOfRowsUpdate?(numberOfRows)
        return numberOfRows
    }

    func configureCell(forRowAt indexPath: IndexPath) -> StatisticsCellModel {
        let config = statisticsData[indexPath.item]
        let statistics = config.getStatistics()
        return .init(description: config.description, value: statistics)
    }

    private func getCompletedTrackersCount() -> String {
        let list = recordsModel.list
        let count = Set(list.map(\.tracker?.id)).count
        return String(count)
    }
}
