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

    @State private var selectedPoint: EMADataPoint?

    private var chartData: [EMADataPoint] {
        let values = heartRates.map { Double($0.value) }
        let emaValues = calculateEMA(for: values)

        return zip(heartRates, emaValues).enumerated().compactMap { index, pair in
            let (heartRate, ema) = pair
            guard let datetime = heartRate.datetime else { return nil }
            return EMADataPoint(id: index, date: datetime, ema: ema)
        }
    }

    private var stats: (max: Int, avg: Int, min: Int) {
        let emas = chartData.map(\.ema)
        guard !emas.isEmpty else { return (0, 0, 0) }
        return (
            max: Int(emas.max() ?? 0),
            avg: Int(emas.reduce(0, +) / Double(emas.count)),
            min: Int(emas.min() ?? 0)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            bpmHeader
            chart
            statsRow
        }
    }

    // MARK: - BPM Header

    @ViewBuilder
    private var bpmHeader: some View {
        let displayValue = selectedPoint ?? chartData.last
        if let point = displayValue {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(point.ema))")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(NowatchTheme.chartOrange)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: Int(point.ema))
                Text("BPM")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(NowatchTheme.secondaryText)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("bpmHeader")
            .accessibilityLabel("Current heart rate: \(Int(point.ema)) beats per minute")
            .padding(.horizontal)
        }
    }

    // MARK: - Chart

    private var chart: some View {
        Chart(chartData) { point in
            AreaMark(
                x: .value("Time", point.date),
                y: .value("Heart Rate", point.ema)
            )
            .foregroundStyle(NowatchTheme.chartFillGradient)
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Time", point.date),
                y: .value("Heart Rate", point.ema)
            )
            .foregroundStyle(NowatchTheme.chartGradient)
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2.5))

            if let selected = selectedPoint, selected.id == point.id {
                PointMark(
                    x: .value("Time", selected.date),
                    y: .value("Heart Rate", selected.ema)
                )
                .symbol(.circle)
                .symbolSize(50)
                .foregroundStyle(NowatchTheme.chartOrange)

                RuleMark(x: .value("Time", selected.date))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(NowatchTheme.secondaryText)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 3)) { _ in
                AxisValueLabel(format: .dateTime.hour().minute())
                    .foregroundStyle(NowatchTheme.secondaryText)
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(NowatchTheme.axisColor)
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(NowatchTheme.secondaryText)
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(NowatchTheme.axisColor)
            }
        }
        .chartYAxisLabel {
            Text("BPM")
                .font(.caption2)
                .foregroundStyle(NowatchTheme.secondaryText)
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let plotOrigin = geo[proxy.plotAreaFrame].origin
                                let x = value.location.x - plotOrigin.x
                                guard let date: Date = proxy.value(atX: x) else { return }
                                selectedPoint = closestPoint(to: date)
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.2)) {
                                    selectedPoint = nil
                                }
                            }
                    )
            }
        }
        .frame(height: 220)
        .padding(.horizontal)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(title: "HR Max", value: stats.max, color: NowatchTheme.chartRed)
            statItem(title: "HR Avg", value: stats.avg, color: NowatchTheme.chartOrange)
            statItem(title: "HR Min", value: stats.min, color: NowatchTheme.chartYellow)
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Heart rate max \(stats.max), average \(stats.avg), min \(stats.min) BPM")
    }

    private func statItem(title: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(NowatchTheme.secondaryText)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(NowatchTheme.primaryText)
                Text("BPM")
                    .font(.caption2)
                    .foregroundStyle(NowatchTheme.secondaryText)
            }
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(height: 3)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func closestPoint(to date: Date) -> EMADataPoint? {
        chartData.min(by: {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        })
    }

    private var accessibilitySummary: String {
        guard !chartData.isEmpty else { return "Heart rate chart with no data" }
        return "Heart rate chart with \(chartData.count) readings. Max \(stats.max), average \(stats.avg), min \(stats.min) BPM."
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
