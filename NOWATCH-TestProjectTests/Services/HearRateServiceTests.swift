//
//  HearRateServiceTests.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import XCTest
import CoreData
@testable import NOWATCH_TestProject

final class HeartRateServiceTests: XCTestCase {

    private var service: HeartRateService!

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        service = HeartRateService(viewContext: controller.container.viewContext)
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func testFetchHeartRatesForSelectedDate() throws {
        let selectedDate = unixTimestampToDate(timestampString: "1714428000")!
        let data = MockHeartRateBuilder.heartRates
        try service.storeBulkData(data: data)

        let fetchedHeartRates = service.fetchHeartRates(selectedDate: selectedDate)

        XCTAssertEqual(fetchedHeartRates.count, 5)
        XCTAssertEqual(fetchedHeartRates[0].value, 50)
        XCTAssertEqual(fetchedHeartRates[1].value, 60)
        XCTAssertEqual(fetchedHeartRates[2].value, 70)
    }

    func testFetchHeartRatesReturnsEmptyForDateWithNoData() {
        let distantPast = Date.distantPast
        let fetched = service.fetchHeartRates(selectedDate: distantPast)
        XCTAssertTrue(fetched.isEmpty)
    }

    func testStoreLiveData() throws {
        try service.storeLiveData(liveHeartRate: 130)

        let fetchedHeartRates = service.fetchHeartRates(selectedDate: Date())

        XCTAssertEqual(fetchedHeartRates.count, 1)
        XCTAssertEqual(fetchedHeartRates[0].value, 130)
    }

    func testStoreBulkData() throws {
        let selectedDate = unixTimestampToDate(timestampString: "1714428000")!
        let data = MockHeartRateBuilder.heartRates
        try service.storeBulkData(data: data)

        let fetchedHeartRates = service.fetchHeartRates(selectedDate: selectedDate)

        XCTAssertEqual(fetchedHeartRates.count, 5)
        XCTAssertEqual(fetchedHeartRates[0].value, 50)
        XCTAssertEqual(fetchedHeartRates[1].value, 60)
        XCTAssertEqual(fetchedHeartRates[2].value, 70)
    }

    func testStoreBulkDataWithEmptyData() throws {
        let data: [(Date, Int32)] = []
        try service.storeBulkData(data: data)

        let fetchedHeartRates = service.fetchHeartRates(selectedDate: Date())

        XCTAssertTrue(fetchedHeartRates.isEmpty)
    }

    func testFetchedHeartRatesAreSortedByDatetime() throws {
        let data = MockHeartRateBuilder.heartRates
        try service.storeBulkData(data: data)

        let selectedDate = unixTimestampToDate(timestampString: "1714428000")!
        let fetched = service.fetchHeartRates(selectedDate: selectedDate)

        for i in 1..<fetched.count {
            XCTAssertTrue(fetched[i].datetime! >= fetched[i - 1].datetime!)
        }
    }
}
