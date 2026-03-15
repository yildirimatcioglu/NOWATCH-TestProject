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

    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func fetchHeartRates(selectedDate: Date) -> [HeartRate] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let fetchRequest: NSFetchRequest<HeartRate> = HeartRate.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "datetime >= %@ AND datetime < %@", startOfDay as CVarArg, endOfDay as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HeartRate.datetime, ascending: true)]

        return (try? viewContext.fetch(fetchRequest)) ?? []
    }

    func storeLiveData(liveHeartRate: Int) throws {
        let newRecord = HeartRate(context: viewContext)
        newRecord.datetime = Date.now
        newRecord.value = Int32(liveHeartRate)
        do {
            try viewContext.save()
        } catch let error {
            print("Failed to save heart rates: \(error)")
            throw error
        }
    }

    func storeBulkData(data: [(Date, Int32)]) throws {
        for row in data {
            let newRecord = HeartRate(context: viewContext)
            newRecord.datetime = row.0
            newRecord.value = row.1
        }
        do {
            try viewContext.save()
        } catch let error {
            print("Failed to save heart rates: \(error)")
            throw error
        }
    }
}
