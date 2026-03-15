//
//  ImportServiceTests.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import XCTest
@testable import NOWATCH_TestProject

class ImportServiceTest: XCTestCase {

    var importService: ImportService!
    var mockHeartRateService: MockHeartRateService!

    override func setUp() {
        super.setUp()
        mockHeartRateService = MockHeartRateService()
        importService = ImportService(heartRateService: mockHeartRateService)
    }

    override func tearDown() {
        mockHeartRateService = nil
        importService = nil
        super.tearDown()
    }

    func testImportHeartRateFromFile() {
        importService.importHeartRateFromFile()
        XCTAssertEqual(mockHeartRateService.storedHeartRates.count, 44344)
    }
}
