//
//  HeartRateViewModelTests.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import XCTest
import CoreData
@testable import NOWATCH_TestProject

@MainActor
final class HeartRateViewModelTests: XCTestCase {

    private var viewModel: HeartRateViewModel!
    private var mockHeartRateService: MockHeartRateService!
    private var mockImportService: MockImportService!
    private var viewContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        viewContext = controller.container.viewContext
        mockHeartRateService = MockHeartRateService()
        mockImportService = MockImportService()
        viewModel = HeartRateViewModel(
            heartRateService: mockHeartRateService,
            importService: mockImportService
        )
    }

    override func tearDown() {
        viewModel = nil
        mockHeartRateService = nil
        mockImportService = nil
        viewContext = nil
        super.tearDown()
    }

    func testFetchHeartRates() {
        let expected = [HeartRate(context: viewContext), HeartRate(context: viewContext)]
        mockHeartRateService.fetchedHeartRates = expected

        viewModel.fetchHeartRates()

        XCTAssertEqual(viewModel.heartRates, expected)
    }

    func testStoreLiveData() {
        let liveHeartRate = 120
        viewModel.storeLiveData(liveHeartRate: liveHeartRate)

        XCTAssertTrue(mockHeartRateService.storeLiveDataCalled)
        XCTAssertTrue(mockHeartRateService.storedHeartRates.contains { $0.1 == Int32(liveHeartRate) })
    }

    func testStoreLiveDataSetsErrorMessageOnFailure() {
        let expectedError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "save failed"])
        mockHeartRateService.storeLiveDataError = expectedError

        viewModel.storeLiveData(liveHeartRate: 80)

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "save failed")
    }

    func testLoadInitialDataCallsImport() async {
        await viewModel.loadInitialData()

        XCTAssertTrue(mockImportService.importCalled)
    }

    func testLoadInitialDataSetsLoading() async {
        XCTAssertFalse(viewModel.isLoading)
        await viewModel.loadInitialData()
        XCTAssertFalse(viewModel.isLoading)
    }

    func testIsTodayReturnsTrueForNow() {
        viewModel.selectedDate = .now
        XCTAssertTrue(viewModel.isToday)
    }

    func testIsTodayReturnsFalseForPastDate() {
        viewModel.selectedDate = Date.distantPast
        XCTAssertFalse(viewModel.isToday)
    }

    func testSelectedDateChangeDoesNotCrash() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        viewModel.selectedDate = yesterday
        XCTAssertEqual(viewModel.selectedDate, yesterday)
    }
}
