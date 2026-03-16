// Created on 30/05/2024

import Charts
import CoreData
import SwiftUI

struct HeartRateView: View {
    @StateObject var viewModel: HeartRateViewModel

    var body: some View {
        ZStack {
            NowatchTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Divider().background(NowatchTheme.axisColor)
                content
            }
        }
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

    // MARK: - Header

    private var header: some View {
        HStack {
            DatePicker(
                "Date",
                selection: $viewModel.selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(NowatchTheme.chartOrange)
            .accessibilityIdentifier("datePicker")
            .accessibilityLabel("Select a date to view heart rate data")
            .accessibilityHint("Shows heart rate recordings for the chosen day")

            Spacer()

            if viewModel.isToday {
                liveIndicator
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var liveIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(NowatchTheme.chartOrange)
                .frame(width: 8, height: 8)
                .modifier(PulseEffect())
            Text("LIVE")
                .font(.caption.bold())
                .foregroundStyle(NowatchTheme.chartOrange)
        }
        .accessibilityIdentifier("liveIndicator")
        .accessibilityLabel("Receiving live heart rate data")
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView()
                .tint(NowatchTheme.chartOrange)
                .accessibilityIdentifier("loadingIndicator")
                .accessibilityLabel("Loading heart rate data")
            Text("Importing heart rate data…")
                .font(.subheadline)
                .foregroundStyle(NowatchTheme.secondaryText)
                .padding(.top, 8)
            Spacer()
        } else if viewModel.heartRates.isEmpty {
            Spacer()
            emptyState
            Spacer()
        } else {
            ScrollView {
                ChartView(
                    heartRates: viewModel.heartRates,
                    selectedDate: viewModel.selectedDate
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("heartRateChart")
                .accessibilityLabel("Heart rate chart")
                .padding(.top, 16)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundStyle(NowatchTheme.secondaryText)
            Text("No Data")
                .font(.title2.bold())
                .foregroundStyle(NowatchTheme.primaryText)
            Text("No heart rate data available\nfor the selected date.")
                .font(.subheadline)
                .foregroundStyle(NowatchTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("emptyState")
        .accessibilityLabel("No heart rate data available for the selected date")
        .padding()
    }
}

// MARK: - Pulse Animation

private struct PulseEffect: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.4 : 1.0)
            .opacity(isPulsing ? 0.6 : 1.0)
            .animation(
                .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}
