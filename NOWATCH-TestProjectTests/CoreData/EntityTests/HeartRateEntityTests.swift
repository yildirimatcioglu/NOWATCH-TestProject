//
//  HeartRateEntityTests.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import XCTest
import CoreData
@testable import NOWATCH_TestProject

class HeartRateTests: XCTestCase {

    // 1. Setup for Tests (create an in-memory context)
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
    }

    // 2. Test Creating a HeartRate Entity
    func testCreateHeartRate() {
        let nowDate = Date()
        let heartRate = HeartRate(context: context)
        heartRate.datetime = nowDate
        heartRate.value = 100

        XCTAssertNotNil(heartRate)
        XCTAssertEqual(heartRate.datetime, nowDate)
        XCTAssertEqual(heartRate.value, 100)
    }

    // 3. Test Accessing Managed Properties
    func testManagedProperties() {
        let heartRate = HeartRate(context: context)
        heartRate.datetime = Date()
        heartRate.value = 100

        XCTAssertEqual(heartRate.datetime, heartRate.primitiveValue(forKey: "datetime") as? Date)
        XCTAssertEqual(heartRate.value, heartRate.primitiveValue(forKey: "value") as? Int32)
    }

    // 4. Test Fetch Request
    func testFetchRequest() {
        let fetchRequest = HeartRate.fetchRequest()
        XCTAssertNotNil(fetchRequest)
        XCTAssertEqual(fetchRequest.entityName, "HeartRate")
    }

    // 5. Test Identifiable Conformance
    func testIdentifiableConformance() {
        let heartRate = HeartRate(context: context)
        XCTAssertNotNil(heartRate.id)
    }
}
