//
//  MockHearRateService.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import Foundation
@testable import NOWATCH_TestProject

final class MockHeartRateService: HeartRateServiceProtocol {
    var fetchedHeartRates: [HeartRate] = []
    var storedHeartRates: [(Date, Int32)] = []

    var storeLiveDataCalled = false
    var storeLiveDataError: Error?

    var storeBulkDataCalled = false
    var storeBulkDataError: Error?

    func fetchHeartRates(selectedDate: Date) -> [HeartRate] {
        fetchedHeartRates
    }

    func storeLiveData(liveHeartRate: Int) throws {
        storeLiveDataCalled = true
        if let error = storeLiveDataError { throw error }
        storedHeartRates.append((Date(), Int32(liveHeartRate)))
    }

    func storeBulkData(data: [(Date, Int32)]) throws {
        storeBulkDataCalled = true
        storedHeartRates = data
        if let error = storeBulkDataError { throw error }
    }
}
