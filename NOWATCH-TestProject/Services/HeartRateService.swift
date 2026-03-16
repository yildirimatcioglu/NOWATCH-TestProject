//
//  HeartRateService.swift
//  NOWATCH-TestProject
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import Foundation
import CoreData

protocol HeartRateServiceProtocol {
    func fetchHeartRates(selectedDate: Date) -> [HeartRate]
    func storeLiveData(liveHeartRate: Int) throws
    func storeBulkData(data: [(Date, Int32)]) throws
}

final class HeartRateService: HeartRateServiceProtocol {

    private let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func fetchHeartRates(selectedDate: Date) -> [HeartRate] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }

        let fetchRequest: NSFetchRequest<HeartRate> = HeartRate.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "datetime >= %@ AND datetime < %@",
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HeartRate.datetime, ascending: true)]

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch heart rates: \(error)")
            return []
        }
    }

    func storeLiveData(liveHeartRate: Int) throws {
        let record = HeartRate(context: viewContext)
        record.datetime = .now
        record.value = Int32(liveHeartRate)
        try viewContext.save()
    }

    func storeBulkData(data: [(Date, Int32)]) throws {
        for (date, value) in data {
            let record = HeartRate(context: viewContext)
            record.datetime = date
            record.value = value
        }
        try viewContext.save()
    }
}
