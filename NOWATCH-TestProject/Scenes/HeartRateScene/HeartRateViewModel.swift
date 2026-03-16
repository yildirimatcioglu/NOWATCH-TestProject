//
//  HeartRateViewModel.swift
//  NOWATCH-TestProject
//
//  Created by Yıldırım Atçıoğlu on 31/05/2024.
//

import Foundation
import CoreData

@MainActor
final class HeartRateViewModel: ObservableObject {

    @Published var selectedDate: Date = .now
    @Published private(set) var heartRates: [HeartRate] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    let heartRateService: HeartRateServiceProtocol
    let importService: ImportServiceProtocol

    init(
        heartRateService: HeartRateServiceProtocol,
        importService: ImportServiceProtocol
    ) {
        self.heartRateService = heartRateService
        self.importService = importService
    }

    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }

        await importService.importHeartRateFromFileIfNeeded()
        fetchHeartRates()
    }

    func fetchHeartRates() {
        heartRates = heartRateService.fetchHeartRates(selectedDate: selectedDate)
    }

    func storeLiveData(liveHeartRate: Int) {
        do {
            try heartRateService.storeLiveData(liveHeartRate: liveHeartRate)
            fetchHeartRates()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
