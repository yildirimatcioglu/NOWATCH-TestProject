// Created on 30/05/2024

import Charts
import CoreData
import SwiftUI

struct HeartRateView: View {
    @StateObject var viewModel: HeartRateViewModel

    var body: some View {
        VStack(spacing: 0) {
            DatePicker(
                "Date",
                selection: $viewModel.selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .padding()
            .accessibilityLabel("Select a date to view heart rate data")
            .accessibilityHint("Shows heart rate recordings for the chosen day")

            Divider()

            content
        }
        .padding()
        .task {
            await viewModel.loadInitialData()
        }
        .onChange(of: viewModel.selectedDate) { _ in
            viewModel.fetchHeartRates()
        }
        .task(id: viewModel.isToday) {
            guard viewModel.isToday else { return }
            for await heartRate in HeartRateEmitter.stream() {
                viewModel.storeLiveData(liveHeartRate: heartRate)
            }
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            if let message = viewModel.errorMessage {
                Text(message)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView {
                Text("Importing heart rate data…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Loading heart rate data")
            Spacer()
        } else if viewModel.heartRates.isEmpty {
            Spacer()
            emptyState
            Spacer()
        } else {
            ChartView(
                heartRates: viewModel.heartRates,
                selectedDate: viewModel.selectedDate
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Heart rate chart")

            if viewModel.isToday {
                Label("Live", systemImage: "waveform.path.ecg")
                    .font(.caption.bold())
                    .foregroundStyle(.red)
                    .padding(.top, 8)
                    .accessibilityLabel("Receiving live heart rate data")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Data")
                .font(.title2.bold())
            Text("No heart rate data available for the selected date.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No heart rate data available for the selected date")
        .padding()
    }
}
