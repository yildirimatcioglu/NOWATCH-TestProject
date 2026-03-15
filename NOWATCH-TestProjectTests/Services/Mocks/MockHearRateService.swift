//
//  MockHearRateService.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import Foundation
@testable import NOWATCH_TestProject

class MockHeartRateService: HeartRateServiceProtocol {
    var fetchedHeartRates: [HeartRate] = [] // Track fetched heart rates
    var storedHeartRates: [(Date, Int32)] = [] // Track stored heart rates
    var storeLiveDataCalled = false // Track if storeLiveData() was called
    var storeBulkDataCalled = false // Track if storeBulkData() was called
    var storeBulkDataError: Error? // For simulating errors in storeBulkData()

    func fetchHeartRates(selectedDate: Date) -> [HeartRate] {
        return fetchedHeartRates
    }

    func storeLiveData(liveHeartRate: Int) throws {
        storeLiveDataCalled = true
        storedHeartRates.append((Date(), Int32(liveHeartRate)))
    }

    func storeBulkData(data: [(Date, Int32)]) throws {
        storeBulkDataCalled = true
        storedHeartRates = data
        if let error = storeBulkDataError {
            throw error
        }
    }
}
