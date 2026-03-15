//
//  ImportService.swift
//  NOWATCH-TestProject
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.
//

import Foundation

protocol ImportServiceProtocol {
    func importHeartRateFromFile()
}

final class ImportService: ImportServiceProtocol {

    let heartRateService: HeartRateServiceProtocol

    init(heartRateService: HeartRateServiceProtocol) {
        self.heartRateService = heartRateService
    }

    func importHeartRateFromFile() {
        parseCSV(fileName: "heartRate")
    }

    private func parseCSV(fileName: String) {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "csv") else {
            print("CSV file not found")
            return
        }

        do {
            let contents = try String(contentsOfFile: filePath, encoding: .utf8)
            let rows = contents.components(separatedBy: "\n")
            var data: [[String]] = []

            for row in rows {
                let columns = row.components(separatedBy: ",")
                data.append(columns)
            }
            data.removeFirst(1)
            storeCSVData(data: data)
        } catch {
            print("Failed to parse CSV: \(error)")
        }
    }

    private func storeCSVData(data: [[String]]) {
        let mappedData = data.compactMap({ row in
            return (
                row.first.unixTimestampToDate(),
                Int32(row.last ?? "")
            )
        })
            .filter { $0.0 != nil && $0.1 != nil }
            .map { ($0.0!, $0.1!) }
        do {
            try heartRateService.storeBulkData(data: mappedData)
        } catch let error {
            print("Failed to store CSV Data: \(error)")
        }
    }
}
