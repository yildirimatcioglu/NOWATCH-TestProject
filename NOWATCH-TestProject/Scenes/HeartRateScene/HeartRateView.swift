// Created on 30/05/2024

import Charts
import CoreData
import SwiftUI

struct HeartRateView: View {
    @StateObject var viewModel: HeartRateViewModel

    @RandomNumberEmitter(interval: 1.0) private var liveHeartRate

    var body: some View {
        VStack {
            DatePicker(
                "Date",
                selection: $viewModel.selectedDate,
                displayedComponents: .date
            )
            .padding()
            if viewModel.heartRates.isEmpty {
                Spacer()
                Text("No data available for the selected date")
                Spacer()
            } else {
                ChartView(heartRates: viewModel.heartRates, selectedDate: viewModel.selectedDate)
            }
        }
        .padding()
        .onChange(of: liveHeartRate) { newValue in
            print("\(Date.now.formatted()): \(newValue) BPM")
            viewModel.storeLiveData(liveHeartRate: newValue)
        }
        .onAppear {
            viewModel.fetchHeartRates()
        }
    }
}
