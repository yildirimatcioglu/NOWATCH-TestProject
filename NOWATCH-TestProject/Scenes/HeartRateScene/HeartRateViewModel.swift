//
//  HeartRateViewModel.swift
//  NOWATCH-TestProject
//
//  Created by Yıldırım Atçıoğlu on 31/05/2024.
//

import Foundation
import Combine
import CoreData

class HeartRateViewModel: ObservableObject {
    var viewContext: NSManagedObjectContext
    @Published var selectedDate: Date = .now
    @Published var heartRates: [HeartRate] = []

    private var cancellables = Set<AnyCancellable>()

    let heartRateService: HeartRateServiceProtocol
    let importService: ImportServiceProtocol

    init(viewContext: NSManagedObjectContext, heartRateService: HeartRateServiceProtocol, importService: ImportServiceProtocol) {
        self.viewContext = viewContext
        self.heartRateService = heartRateService
        self.importService = importService

        getHeartRatesFromLocaleFile()

        $selectedDate
            .sink { [weak self] date in
                self?.fetchHeartRates()
            }
            .store(in: &cancellables)
    }

    func storeLiveData(liveHeartRate: Int) {
        do {
            try heartRateService.storeLiveData(liveHeartRate: liveHeartRate)
            fetchHeartRates()
        } catch {
            // show Error here.
        }
    }

    func fetchHeartRates() {
        let heartRatesList = heartRateService.fetchHeartRates(selectedDate: selectedDate)
        heartRates = heartRatesList
    }

    func getHeartRatesFromLocaleFile() {
        importService.importHeartRateFromFile()
    }
}
