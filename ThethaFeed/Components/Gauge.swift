//
//  Gauge.swift
//  ThethaFeed
//
//  Created by Joana Choong on 15/02/2026.
//

import SwiftUI

// MARK: - Constants

/// Size of the circular risk gauge in points
private let gaugeSize: CGFloat = 214
private let gaugeSizeL: CGFloat = 214 / 2
/// Thickness of the gauge ring stroke
private let gaugeStroke: CGFloat = 30

// MARK: - GaugeSegmentShape

/// Custom SwiftUI Shape for the gauge arc with green/yellow/red segments.
/// Represents the risk gauge's colored arc background.
struct GaugeSegmentShape: Shape {
    /// Start angle in degrees
    let startAngle: Double
    /// End angle in degrees
    let endAngle: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - gaugeStroke / 2

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )

        return path
    }
}

// MARK: - NeedleShape

/// Custom SwiftUI Shape for the gauge needle (droplet shape).
/// Red droplet-shaped indicator that swings based on risk level.
struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let centerX = rect.midX
        let centerY = rect.midY

        path.move(to: CGPoint(x: centerX - 13, y: centerY))
        path.addLine(to: CGPoint(x: centerX, y: centerY - 60))
        path.addLine(to: CGPoint(x: centerX + 13, y: centerY))
        path.closeSubpath()

        return path
    }
}

// MARK: - GaugeView

/// Reusable gauge component displaying a semicircular risk meter with
/// green/yellow/red segments, an animated needle, and a center pivot dot.
///
/// - Parameter needleAngle: The rotation angle of the needle in degrees
///   (-90 = far left / safe, 0 = center, +90 = far right / danger).
struct GaugeView: View {
    /// Needle rotation angle in degrees (-90 to +90)
    let needleAngle: Double

    var body: some View {
        ZStack {
            // Green segment (safe zone) - left third of semicircle
            GaugeSegmentShape(startAngle: 180, endAngle: 240)
                .stroke(Color(hex: "#22C55E"), lineWidth: gaugeStroke)
                .frame(width: gaugeSize, height: gaugeSize)

            // Yellow segment (caution zone) - middle third of semicircle
            GaugeSegmentShape(startAngle: 240, endAngle: 300)
                .stroke(Color(hex: "#EAB308"), lineWidth: gaugeStroke)
                .frame(width: gaugeSize, height: gaugeSize)

            // Red segment (danger zone) - right third of semicircle
            GaugeSegmentShape(startAngle: 300, endAngle: 360)
                .stroke(Color(hex: "#EF4444"), lineWidth: gaugeStroke)
                .frame(width: gaugeSize, height: gaugeSize)

            // Animated needle
            NeedleShape()
                .fill(Color(hex: "#EF4444"))
                .frame(width: 30, height: 60)
                .offset(y: -5)
                .rotationEffect(.degrees(needleAngle))

            // Center dot covering the needle pivot
            Circle()
                .fill(Color(hex: "#EF4444"))
                .frame(width: 30, height: 30)
        }
        .frame(width: gaugeSizeL, height: gaugeSizeL)
    }
}

// MARK: - Preview

#Preview {
    GaugeView(needleAngle: 0)
        .background(Color.black)
}
