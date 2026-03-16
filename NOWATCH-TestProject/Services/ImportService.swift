//
//  ImportService.swift
//  NOWATCH-TestProject
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import Foundation
import CoreData

protocol ImportServiceProtocol {
    func importHeartRateFromFileIfNeeded() async
}

final class ImportService: ImportServiceProtocol {

    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func importHeartRateFromFileIfNeeded() async {
        let alreadyImported = await hasExistingData()
        guard !alreadyImported else { return }

        guard let records = parseCSV(fileName: "heartRate") else { return }
        await insertRecords(records)
    }

    private func hasExistingData() async -> Bool {
        let context = container.newBackgroundContext()
        return await context.perform {
            let request: NSFetchRequest<HeartRate> = HeartRate.fetchRequest()
            request.fetchLimit = 1
            return ((try? context.count(for: request)) ?? 0) > 0
        }
    }

    private func parseCSV(fileName: String) -> [(Date, Int32)]? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
            return nil
        }

        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            return contents
                .components(separatedBy: .newlines)
                .dropFirst()
                .compactMap { row -> (Date, Int32)? in
                    let columns = row.components(separatedBy: ",")
                    guard columns.count >= 2,
                          let timestamp = TimeInterval(columns[0].trimmingCharacters(in: .whitespaces)),
                          let value = Int32(columns[1].trimmingCharacters(in: .whitespacesAndNewlines))
                    else { return nil }
                    return (Date(timeIntervalSince1970: timestamp), value)
                }
        } catch {
            return nil
        }
    }

    private func insertRecords(_ records: [(Date, Int32)]) async {
        let batchSize = 5_000
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        await context.perform {
            for (index, (date, value)) in records.enumerated() {
                let record = HeartRate(context: context)
                record.datetime = date
                record.value = value

                if (index + 1).isMultiple(of: batchSize) {
                    do {
                        try context.save()
                        context.reset()
                    } catch {
                        context.rollback()
                    }
                }
            }

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    context.rollback()
                }
            }
        }
    }
}
