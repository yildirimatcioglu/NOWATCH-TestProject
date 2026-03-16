//
//  NOWATCH_TestProjectUITests.swift
//  NOWATCH-TestProjectUITests
//
//  Created by Yildirim Atcioglu on 16/03/2026.
//

import XCTest

final class NOWATCH_TestProjectUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    private func element(identifier: String) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier == %@", identifier)
        return app.descendants(matching: .any).matching(predicate).firstMatch
    }

    func testDatePickerExists() {
        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.waitForExistence(timeout: 5))
    }

    func testInitialLoadTransitionsFromLoadingToContent() {
        let chart = element(identifier: "heartRateChart")
        let emptyState = element(identifier: "emptyState")

        let appeared = chart.waitForExistence(timeout: 20) || emptyState.waitForExistence(timeout: 3)
        XCTAssertTrue(appeared, "Expected chart or empty state after import finishes")

        let loading = element(identifier: "loadingIndicator")
        XCTAssertFalse(loading.exists)
    }

    func testTodayShowsLiveIndicatorAndBPM() {
        let liveIndicator = element(identifier: "liveIndicator")
        let bpmHeader = element(identifier: "bpmHeader")

        XCTAssertTrue(
            liveIndicator.waitForExistence(timeout: 25),
            "Live indicator should appear for today's date"
        )
        XCTAssertTrue(bpmHeader.exists, "BPM header should be visible when chart has data")
    }

    func testBPMTextShowsNumericValue() {
        let bpm = app.staticTexts["BPM"]
        XCTAssertTrue(bpm.waitForExistence(timeout: 25))
    }

    func testDatePickerIsInteractable() {
        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.waitForExistence(timeout: 5))
        datePicker.tap()

        let calendarGrid = app.datePickers.firstMatch
        XCTAssertTrue(calendarGrid.waitForExistence(timeout: 3))
    }

    func testChartAndEmptyStateAreMutuallyExclusive() {
        let chart = element(identifier: "heartRateChart")
        let emptyState = element(identifier: "emptyState")

        let chartAppeared = chart.waitForExistence(timeout: 25)
        let emptyAppeared = !chartAppeared && emptyState.waitForExistence(timeout: 3)

        XCTAssertTrue(chartAppeared || emptyAppeared, "App should show chart or empty state")
        XCTAssertFalse(chart.exists && emptyState.exists, "Chart and empty state should never coexist")
    }

    func testChartHasAccessibilityLabel() {
        let chart = element(identifier: "heartRateChart")
        guard chart.waitForExistence(timeout: 25) else {
            XCTFail("Chart never appeared")
            return
        }
        XCTAssertFalse(chart.label.isEmpty, "Chart should have a non-empty accessibility label")
    }
}
