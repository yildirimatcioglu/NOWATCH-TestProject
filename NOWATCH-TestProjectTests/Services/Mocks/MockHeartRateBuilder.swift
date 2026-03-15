//
//  MockHeartRateBuilder.swift
//  NOWATCH-TestProjectTests
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import Foundation
@testable import NOWATCH_TestProject

enum MockHeartRateBuilder {
    static let heartRates: [(Date, Int32)] = [
        (unixTimestampToDate(timestampString: "1714428000")!, 50),
        (unixTimestampToDate(timestampString: "1714428060")!, 60),
        (unixTimestampToDate(timestampString: "1714428120")!, 70),
        (unixTimestampToDate(timestampString: "1714428180")!, 80),
        (unixTimestampToDate(timestampString: "1714428240")!, 90)
    ]
}

func unixTimestampToDate(timestampString: String?) -> Date? {
    guard let timestampString,
          let timestamp = TimeInterval(timestampString)
    else { return nil}
    return Date(timeIntervalSince1970: timestamp)
}
