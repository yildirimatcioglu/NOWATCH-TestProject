//
//  MockImportService.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import Foundation
@testable import NOWATCH_TestProject

final class MockImportService: ImportServiceProtocol {
    var importCalled = false

    func importHeartRateFromFileIfNeeded() async {
        importCalled = true
    }
}
