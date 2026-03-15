//
//  HearRateServiceTests.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import XCTest
import CoreData
@testable import NOWATCH_TestProject

class HeartRateServiceTests: XCTestCase {

    // MARK: - Properties

    var service: HeartRateService!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        service = HeartRateService(viewContext: controller.container.newBackgroundContext())
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testFetchHeartRatesForSelectedDate() {
        let selectedDate = unixTimestampToDate(timestampString: "1714428000")!
        let data = MockHeartRateBuilder.heartRates
        try! service.storeBulkData(data: data)

        // Fetch heart rates for the selected date
        let fetchedHeartRates = service.fetchHeartRates(selectedDate: selectedDate)

        XCTAssertEqual(fetchedHeartRates.count, 5)
        XCTAssertEqual(fetchedHeartRates[0].value, 50)
        XCTAssertEqual(fetchedHeartRates[1].value, 60)
        XCTAssertEqual(fetchedHeartRates[2].value, 70)
    }

    func testStoreLiveData() throws {
        // Store live heart rate data
        try service.storeLiveData(liveHeartRate: 130)

        // Fetch the stored data
        let fetchedHeartRates = service.fetchHeartRates(selectedDate: Date())

        // Assertions
        XCTAssertEqual(fetchedHeartRates.count, 1)
        XCTAssertEqual(fetchedHeartRates[0].value, 130)
    }

    func testStoreBulkData() throws {
        let selectedDate = unixTimestampToDate(timestampString: "1714428000")!
        let data = MockHeartRateBuilder.heartRates
        try service.storeBulkData(data: data)

        // Fetch the stored data
        let fetchedHeartRates = service.fetchHeartRates(selectedDate: selectedDate)

        // Assertions
        XCTAssertEqual(fetchedHeartRates.count, 5)
        XCTAssertEqual(fetchedHeartRates[0].value, 50)
        XCTAssertEqual(fetchedHeartRates[1].value, 60)
        XCTAssertEqual(fetchedHeartRates[2].value, 70)
    }

    func testStoreBulkDataWithEmptyData() throws {
        // Store empty bulk data
        let data: [(Date, Int32)] = []
        try service.storeBulkData(data: data)

        // Fetch the stored data
        let fetchedHeartRates = service.fetchHeartRates(selectedDate: Date())

        // Assertions
        XCTAssertEqual(fetchedHeartRates.count, 0)
    }
}
