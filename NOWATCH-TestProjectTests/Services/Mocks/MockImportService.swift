//
//  MockImportService.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import Foundation
@testable import NOWATCH_TestProject

class MockImportService: ImportServiceProtocol {
    let heartRateService: HeartRateServiceProtocol

    var importHeartRateFromFileCalled = false // Track if importHeartRateFromFile() was called

    init(heartRateService: HeartRateServiceProtocol) {
        self.heartRateService = heartRateService
    }

    func importHeartRateFromFile() {
        importHeartRateFromFileCalled = true
        let mockBulkData = MockHeartRateBuilder.heartRates
        do {
            try heartRateService.storeBulkData(data: mockBulkData)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
