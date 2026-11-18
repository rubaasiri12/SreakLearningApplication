import Foundation
import SwiftData
import Combine

////////////////////////////////////////////////////////////////////////////////
/// DATA STORAGE FOR: PROGRESS (every logged day)          → SwiftData (StorageDB)
///
/// What it keeps: one record per day the user logged, Learned or Freezed,
/// for the week / month / year goal. The progress grows every day, so it lives
/// in a small database.
/// Used by: ActivityViewModel (Task 2), CalendarViewModel (Task 5).
/// Change this file to change how progress is saved.
////////////////////////////////////////////////////////////////////////////////

/// One row in the database = one logged day.
@Model
final class DayRecord {
    /// The day (always midnight), unique: one record per day.
    @Attribute(.unique) var day: Date
    /// "learned" or "freezed".
    var statusRaw: String

    init(day: Date, status: DayStatus) {
        self.day = day
        self.statusRaw = status.rawValue
    }

    var status: DayStatus {
        get { DayStatus(rawValue: statusRaw) ?? .learned }
        set { statusRaw = newValue.rawValue }
    }
}

/// Reads and writes DayRecords. ViewModels talk to this, never to SwiftData directly.
final class ProgressStorageDB: ObservableObject {
    /// All logged days, ready to read: "2026-11-18" → .learned
    @Published private(set) var days: [String: DayStatus] = [:]

    private let container: ModelContainer
    private let context: ModelContext

    /// - Parameter inMemory: `true` for previews (nothing saved on the phone).
    init(inMemory: Bool = false) {
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(for: DayRecord.self, configurations: config)
        } catch {
            fatalError("Could not create the progress database: \(error)")
        }
        context = ModelContext(container)
        reload()
    }

    /// Sets one day to Learned, Freezed, or nil (removes the record).
    func setStatus(_ status: DayStatus?, on date: Date) {
        let target = AppCalendar.startOfDay(date)
        let existing = try? context.fetch(
            FetchDescriptor<DayRecord>(predicate: #Predicate { $0.day == target })
        ).first

        switch (status, existing) {
        case let (status?, record?): record.status = status                          // change
        case let (status?, nil): context.insert(DayRecord(day: target, status: status)) // add
        case let (nil, record?): context.delete(record)                               // remove
        case (nil, nil): break
        }
        try? context.save()
        reload()
    }

    /// Deletes every record (handy for testing).
    func deleteAll() {
        try? context.delete(model: DayRecord.self)
        try? context.save()
        reload()
    }

    private func reload() {
        let records = (try? context.fetch(FetchDescriptor<DayRecord>())) ?? []
        days = Dictionary(records.map { (AppCalendar.key($0.day), $0.status) },
                          uniquingKeysWith: { first, _ in first })
    }
}
