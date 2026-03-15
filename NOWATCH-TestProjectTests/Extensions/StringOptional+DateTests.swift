//
//  StringOptional+Date.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import XCTest
@testable import NOWATCH_TestProject

class OptionalStringExtensionTests: XCTestCase {

    func testUnixTimestampToDate_ValidTimestamp() {
        let timestampString: String? = "1714428000"
        let expectedDate = Date(timeIntervalSince1970: 1714428000)
        let actualDate = timestampString.unixTimestampToDate()

        XCTAssertEqual(actualDate, expectedDate)
    }

    func testUnixTimestampToDate_InvalidTimestamp() {
        let timestampString: String? = "invalid"
        let actualDate = timestampString.unixTimestampToDate()

        XCTAssertNil(actualDate)
    }

    func testUnixTimestampToDate_NilTimestamp() {
        let timestampString: String? = nil
        let actualDate = timestampString.unixTimestampToDate()

        XCTAssertNil(actualDate)
    }
}
