//
//  ImportServiceTests.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import XCTest
import CoreData
@testable import NOWATCH_TestProject

final class ImportServiceTests: XCTestCase {

    private var importService: ImportService!
    private var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        container = controller.container
        importService = ImportService(container: container)
    }

    override func tearDown() {
        importService = nil
        container = nil
        super.tearDown()
    }

    func testImportHeartRateFromFile() async throws {
        await importService.importHeartRateFromFileIfNeeded()

        let context = container.newBackgroundContext()
        let count = try await context.perform {
            try context.count(for: HeartRate.fetchRequest())
        }

        XCTAssertEqual(count, 44344)
    }

    func testImportSkipsWhenDataAlreadyExists() async throws {
        await importService.importHeartRateFromFileIfNeeded()

        let context = container.newBackgroundContext()
        let firstCount = try await context.perform {
            try context.count(for: HeartRate.fetchRequest())
        }

        await importService.importHeartRateFromFileIfNeeded()

        let secondCount = try await context.perform {
            try context.count(for: HeartRate.fetchRequest())
        }

        XCTAssertEqual(firstCount, secondCount, "Second import should be a no-op")
    }
}
