//
//  StringOptional+Date.swift
//  NOWATCH-TestProject
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import Foundation

extension Optional where Wrapped == String {
    func unixTimestampToDate() -> Date? {
        guard let timestampString = self,
              let timestamp = TimeInterval(timestampString) else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
}
