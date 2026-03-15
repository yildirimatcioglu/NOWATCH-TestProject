//
//  ChartView.swift
//  NOWATCH-TestProject
//
//  Created by Yıldırım Atçıoğlu on 31/05/2024.
//

import SwiftUI
import Charts

struct ChartView: View {
    var heartRates: [HeartRate]
    let selectedDate: Date

    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffset: CGFloat = 0.0

    var body: some View {
        let emaData = calculateEMA(for: heartRates.map { Double($0.value) })
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack {
                    Chart {
                        ForEach(heartRates.indices, id: \.self) { index in
                            if let datetime = heartRates[index].datetime {
                                if index < emaData.count {
                                    LineMark(
                                        x: .value("Date", datetime),
                                        y: .value("EMA", emaData[index])
                                    )
                                    .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .hour, count: 1)) { value in
                            AxisValueLabel(format: .dateTime.hour(), centered: true)
                            AxisTick(centered: true, length: 4, stroke: StrokeStyle(lineWidth: 1))
                            AxisGridLine()
                        }
                    }
                    .frame(width: max(geometry.size.width, geometry.size.width * currentScale))
                }
                .offset(x: currentOffset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            currentScale = value.magnitude
                        }
                        .simultaneously(with: DragGesture()
                            .onChanged { value in
                                currentOffset = value.translation.width
                            }
                        )
                )
            }
        }
    }

    private func calculateEMA(for values: [Double], period: Int = 10) -> [Double] {
        guard !values.isEmpty else { return [] }

        let k = 2.0 / Double(period + 1)
        var emaValues: [Double] = [values[0]]

        for i in 1..<values.count {
            let ema = values[i] * k + emaValues[i - 1] * (1 - k)
            emaValues.append(ema)
        }

        return emaValues
    }
}
