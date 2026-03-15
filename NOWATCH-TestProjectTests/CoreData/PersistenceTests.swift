//
//  PersistenceTests.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import Foundation
import XCTest
import CoreData
@testable import NOWATCH_TestProject

class PersistenceControllerTests: XCTestCase {

    func testSaveAndFetchHeartRate() {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // 1. Create a new HeartRate entity
        let newHeartRate = HeartRate(context: context)
        newHeartRate.datetime = Date()
        newHeartRate.value = 100

        // 2. Save the context
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save: \(error)")
        }

        // 3. Fetch the HeartRate from the context
        let fetchRequest = NSFetchRequest<HeartRate>(entityName: "HeartRate")
        do {
            let fetchedHeartRates = try context.fetch(fetchRequest)
            XCTAssertGreaterThanOrEqual(fetchedHeartRates.count, 1)

            // 4. Verify the fetched data
            if let fetchedHeartRate = fetchedHeartRates.first {
                XCTAssertEqual(fetchedHeartRate.datetime, newHeartRate.datetime)
                XCTAssertEqual(fetchedHeartRate.value, newHeartRate.value)
            } else {
                XCTFail("Failed to find the saved HeartRate")
            }
        } catch {
            XCTFail("Failed to fetch: \(error)")
        }
    }

    func testFetchAllHeartRates() {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Create 5 test data
        for _ in 0..<5 {
            let newHeartRate = HeartRate(context: context)
            newHeartRate.datetime = Date()
            newHeartRate.value = Int32.random(in: 60 ... 120)
        }

        do {
            try context.save()
        } catch {
            XCTFail("Failed to save: \(error)")
        }

        // Fetch all HeartRates
        let fetchRequest = NSFetchRequest<HeartRate>(entityName: "HeartRate")
        do {
            let fetchedHeartRates = try context.fetch(fetchRequest)
            XCTAssertEqual(fetchedHeartRates.count, 5)
        } catch {
            XCTFail("Failed to fetch: \(error)")
        }
    }
}
