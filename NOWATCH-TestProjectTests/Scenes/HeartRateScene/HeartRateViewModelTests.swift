//
//  HeartRateViewModelTests.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import XCTest
import Combine
import CoreData
@testable import NOWATCH_TestProject


class HeartRateViewModelTests: XCTestCase {

    var viewModel: HeartRateViewModel!
    var mockHeartRateService: MockHeartRateService!
    var mockImportService: MockImportService!
    var viewContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        viewContext = controller.container.newBackgroundContext()
        mockHeartRateService = MockHeartRateService()
        mockImportService = MockImportService(heartRateService: mockHeartRateService)

        // Initialize the viewModel
        viewModel = HeartRateViewModel(viewContext: viewContext, heartRateService: mockHeartRateService, importService: mockImportService)
    }

    override func tearDown() {
        viewModel = nil
        mockHeartRateService = nil
        mockImportService = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testFetchHeartRates() {
        let expectedHeartRates = [HeartRate(context: viewContext), HeartRate(context: viewContext)]
        mockHeartRateService.fetchedHeartRates = expectedHeartRates
        let testDate = Date()
        viewModel.selectedDate = testDate
        viewModel.fetchHeartRates()
        XCTAssertEqual(viewModel.heartRates, expectedHeartRates)
    }

    func testStoreLiveData() {
        let liveHeartRate = 120
        viewModel.storeLiveData(liveHeartRate: liveHeartRate)
        XCTAssertTrue(mockHeartRateService.storeLiveDataCalled)
        XCTAssertTrue(mockHeartRateService.storedHeartRates.contains(where: {
            $0.1 == liveHeartRate
        }))
    }

    func testGetHeartRatesFromLocaleFile() {
        viewModel.getHeartRatesFromLocaleFile()
        XCTAssertTrue(mockImportService.importHeartRateFromFileCalled)
    }

    func testSelectedDateSink() {
        let testDate = Date().addingTimeInterval(-60 * 60 * 24) // One day earlier
        viewModel.selectedDate = testDate
        XCTAssertEqual(viewModel.selectedDate, testDate)
    }
}
