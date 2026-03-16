//
//  ChartView.swift
//  NOWATCH-TestProject
//
//  Created by Yıldırım Atçıoğlu on 31/05/2024.
//

import SwiftUI
import Charts

struct ChartView: View {
    let heartRates: [HeartRate]
    let selectedDate: Date

    private var chartData: [EMADataPoint] {
        let values = heartRates.map { Double($0.value) }
        let emaValues = calculateEMA(for: values)

        return zip(heartRates, emaValues).enumerated().compactMap { index, pair in
            let (heartRate, ema) = pair
            guard let datetime = heartRate.datetime else { return nil }
            return EMADataPoint(id: index, date: datetime, ema: ema)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            latestReadingHeader
            chart
        }
    }

    @ViewBuilder
    private var latestReadingHeader: some View {
        if let latest = chartData.last {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(latest.ema))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.red)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: Int(latest.ema))
                Text("BPM")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Current heart rate: \(Int(latest.ema)) beats per minute")
            .padding(.horizontal)
        }
    }

    private var chart: some View {
        Chart(chartData) { point in
            AreaMark(
                x: .value("Time", point.date),
                y: .value("Heart Rate", point.ema)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [.red.opacity(0.25), .red.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Time", point.date),
                y: .value("Heart Rate", point.ema)
            )
            .foregroundStyle(.red)
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
        .chartYAxisLabel("BPM")
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 3)) { _ in
                AxisValueLabel(format: .dateTime.hour().minute())
                AxisTick()
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel()
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
            }
        }
        .padding(.horizontal)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        guard let minEma = chartData.map(\.ema).min(),
              let maxEma = chartData.map(\.ema).max()
        else {
            return "Heart rate chart with no data"
        }
        let avg = chartData.map(\.ema).reduce(0, +) / Double(chartData.count)
        return "Heart rate chart with \(chartData.count) readings. Range: \(Int(minEma)) to \(Int(maxEma)) BPM. Average: \(Int(avg)) BPM."
    }

    private func calculateEMA(for values: [Double], period: Int = 10) -> [Double] {
        guard let first = values.first else { return [] }

        let multiplier = 2.0 / Double(period + 1)
        var result = [Double]()
        result.reserveCapacity(values.count)
        result.append(first)

        for i in 1..<values.count {
            let ema = values[i] * multiplier + result[i - 1] * (1 - multiplier)
            result.append(ema)
        }

        return result
    }
}

private struct EMADataPoint: Identifiable {
    let id: Int
    let date: Date
    let ema: Double
}
