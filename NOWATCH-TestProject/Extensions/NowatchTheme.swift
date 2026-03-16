//
//  NowatchTheme.swift
//  NOWATCH-TestProject
//
//  Created by Yıldırım Atçıoğlu on 16/03/2026.
//

import SwiftUI

enum NowatchTheme {
    static let background = Color(red: 0.04, green: 0.04, blue: 0.05)
    static let cardBackground = Color(red: 0.10, green: 0.10, blue: 0.12)

    static let chartOrange = Color(red: 0.95, green: 0.55, blue: 0.15)
    static let chartYellow = Color(red: 0.98, green: 0.75, blue: 0.20)
    static let chartRed = Color(red: 0.90, green: 0.25, blue: 0.20)

    static let chartGradient = LinearGradient(
        colors: [chartYellow, chartOrange, chartRed],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let chartFillGradient = LinearGradient(
        colors: [chartOrange.opacity(0.35), chartOrange.opacity(0.0)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let primaryText = Color.white
    static let secondaryText = Color(white: 0.5)
    static let axisColor = Color(white: 0.25)
}
