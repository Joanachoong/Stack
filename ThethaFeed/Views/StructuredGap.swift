//
//  StructuredGap.swift
//  ThethaFeed
//
//  Created by Joana Choong on 25/02/2026.
//

import SwiftUI

// MARK: - StructuredGapView
// Animated bar chart showing the gap between Expected vs Actual progress.
// Animation sequence:
//  1. Empty grey bars appear (no numbers, no colour)
//  2. Numbers count 0% → target simultaneously while bars grow bottom-up (0.5 s)
//  3. Title fades in (0.3 s)
//  4. NEXT button fades in (0.3 s)

struct StructuredGapView: View {
    let onNext: () -> Void

    // MARK: - Layout constants
    private let barWidth: CGFloat  = 100
    private let barHeight: CGFloat = 230
    private let expectedTarget     = 80   // %
    private let actualTarget       = 50   // %

    // MARK: - Colors
    private let neonGreen  = AppColors.primary
    private let actualRed  = Color(hex: "#EF4444")
    private let cardBG     = Color(hex: "#1A1A1A")
    private let barBG      = Color(white: 0.32)

    // MARK: - Animation state
    @State private var expectedNumber: Int  = 0
    @State private var actualNumber:   Int  = 0
    @State private var numberOpacity: Double = 0

    @State private var expectedFillH: CGFloat = 0
    @State private var actualFillH:   CGFloat = 0
    @State private var barOpacity:   Double   = 0

    @State private var titleOpacity:  Double  = 0
    @State private var titleOffset:   CGFloat = 20   // ADDED: slide-up start offset for title text
    @State private var buttonOpacity: Double  = 0

    // MARK: - Body

    var body: some View {
        ZStack {
            // ── Background ──────────────────────────────────────────────────
            AppColors.background.ignoresSafeArea()

            LinearGradient(
                colors: [AppColors.primary.opacity(0.18), Color.clear],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.35)
            )
            .ignoresSafeArea()

            // ── Content 
            VStack(alignment: .center, spacing: 0) {
                Spacer()

                // Chart card
                VStack(spacing: 15) {
                    // Column headers
                    HStack(spacing: 60) {
                        Text("With\nStackAi")
                            .font(.system(size: 17 ))
                            .foregroundColor(neonGreen)
                            .frame(maxWidth: 60)

                        Text("Without\nStackAi")
                            .font(.system(size: 17))
                            .foregroundColor(actualRed)
                           
                            .frame(maxWidth: 70)
                    }
                    .padding(.bottom, 20)


                    // Bars
                    HStack(spacing: 40) {
                        barView(fillColor: neonGreen,
                                fillHeight: expectedFillH,
                                number: expectedNumber)
                        
                        barView(fillColor: actualRed,
                                fillHeight: actualFillH,
                                number: actualNumber)
                    }
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.5))
                )
                .padding(.horizontal, 24)

                // Title
                Text("Users who don't follow\nrun into issues.")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 36)
                    .padding(.horizontal, 24)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)   // ADDED: slide-up offset for entrance animation

                Spacer()

                // NEXT button
                PrimaryButton(title: "NEXT", action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                    .padding(.top, 24)
                    .opacity(buttonOpacity)
            }
        }
        .onAppear { animateSequence() }
    }

    // MARK: - Bar sub-view

    @ViewBuilder
    private func barView(fillColor: Color,
                         fillHeight: CGFloat,
                         number: Int) -> some View {
        ZStack(alignment: .bottom) {
            // Grey background
            RoundedRectangle(cornerRadius: 16)
                .fill(barBG)
                .frame(width: barWidth, height: barHeight)

            // Coloured fill — grows upward from the bottom
            RoundedRectangle(cornerRadius: 16)
                .fill(fillColor)
                .frame(width: barWidth,
                       height: max(fillHeight, 0))
                .opacity(barOpacity)

            // Percentage label (always at the bottom)
            Text("\(number)%")
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(.black)
                .padding(.bottom, 14)
                .opacity(numberOpacity)
        }
        .frame(width: barWidth, height: barHeight)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Animation sequence

    private func animateSequence() {

        // ── Step 1 (t = 0, 0.5 s): numbers count up + bars grow simultaneously ──

        // Numbers appear immediately and count upward
        numberOpacity = 1

        let countSteps = 40
        let countDuration = 1.2
        let stepInterval  = countDuration / Double(countSteps)

        for step in 0 ... countSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * stepInterval) {
                let pct = Double(step) / Double(countSteps)
                expectedNumber = Int(pct * Double(expectedTarget))
                actualNumber   = Int(pct * Double(actualTarget))
            }
        }

        // Bars: snap opacity on, then animate height from bottom
        withAnimation(.easeIn(duration: 0.5)) {
            barOpacity = 1
        }
        withAnimation(.linear(duration: 1.2)) {
            expectedFillH = barHeight * CGFloat(expectedTarget) / 100
            actualFillH   = barHeight * CGFloat(actualTarget)   / 100
        }

        // ── Step 2 (t = 0.5 s, 0.3 s): title fades in ──────────────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 1.0)) {
                titleOpacity = 1
                titleOffset = 0   // ADDED: animate to resting position
            }
        }

        // ── Step 3 (t = 0.8 s, 0.3 s): button fades in ─────────────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 1.0)) {
                buttonOpacity = 1
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .center, spacing: 0) {
        StructuredGapView(onNext: {})
    }
    .padding(0)
    .background(.white)
}
