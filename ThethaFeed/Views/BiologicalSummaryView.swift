/**
 * @file BiologicalSummaryView.swift
 * @description Animated summary review screen for the ThethaFeed onboarding flow.
 *
 * Animation sequence (3s total):
 *  0.0s  — Title fades + slides up; card box fades in
 *  0.3s  — Subtitle fades in; labels fade + slide up
 *  0.6s  — Values fade in; numeric values count up from 0 → target (0.7s linear)
 *  1.8s  — Continue button fades + slides up
 */

import SwiftUI

// MARK: - Types
// Uses SummaryItem from QuestionModels.swift

// MARK: - BiologicalSummaryView

struct BiologicalSummaryView: View {
    var onComplete: () -> Void
    var items: [SummaryItem]

    // MARK: - Animation State

    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20

    @State private var subtitleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 20

    @State private var cardOpacity: Double = 0

    @State private var labelsOpacity: Double = 0
    @State private var labelsOffset: CGFloat = 16

    @State private var valuesOpacity: Double = 0
    /// Holds the current display string for each row; numeric slots count up via Timer.
    @State private var displayValues: [String] = []

    /// Per-item animation state for alternating left-right effect
    @State private var labelOffsets: [CGFloat] = []
    @State private var labelOpacities: [Double] = []
    @State private var valueOffsets: [CGFloat] = []
    @State private var valueOpacities: [Double] = []

    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 20

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Subtle green glow at top
            LinearGradient(
                colors: [AppColors.primary.opacity(0.18), Color.clear],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.35)
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                Text("Review Summary")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(AppColors.text)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
                    .padding(.horizontal, 24)

                // Subtitle
                Text("Here are the details")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textMuted)
                    .multilineTextAlignment(.center)
                    .opacity(subtitleOpacity)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    .padding(.bottom, 28) .offset(y: subtitleOffset)

                // Summary card
                VStack(spacing: 0) {
                    
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        VStack(spacing: 0) {
                            HStack(spacing: 20) {
                                
                                Text(item.label)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.5))
                                    .opacity(labelOpacities.indices.contains(index) ? labelOpacities[index] : 0)
                                    .offset(x: labelOffsets.indices.contains(index) ? labelOffsets[index] : 0)
                                
                                Spacer()

                                Text(displayValue(for: item))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppColors.text)
                                    .opacity(valueOpacities.indices.contains(index) ? valueOpacities[index] : 0)
                                    .offset(x: valueOffsets.indices.contains(index) ? valueOffsets[index] : 0)
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 30)
                            
                            if index < items.count - 1 {
                                Divider()
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.surfaceSelected)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .opacity(cardOpacity)

                Spacer()

                // Continue button
                PrimaryButton(title: "CONTINUE", action: onComplete)
                    .opacity(buttonOpacity)
                    .offset(y: buttonOffset)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            initDisplayValues()
            startAnimationSequence()
        }
    }

    // MARK: - Helpers

    /// Populates `displayValues` with initial strings before animation starts.
    /// Numeric slots start at "0<unit>" so counting begins from zero.
    private func initDisplayValues() {
        displayValues = items.map { item in
            let scanner = Scanner(string: item.value)
            if scanner.scanDouble() != nil {
                return "0\(numericUnit(from: item.value))"  // e.g. "0 kg", "0"
            }
            return item.value
        }
        
        // Initialize per-item animation arrays
        labelOffsets = items.map { _ in 0 }
        labelOpacities = items.map { _ in 0 }
        valueOffsets = items.map { _ in 0 }
        valueOpacities = items.map { _ in 0 }
    }

    /// Returns the current display string for a row, read from `displayValues`.
    private func displayValue(for item: SummaryItem) -> String {
        guard let index = items.firstIndex(where: { $0.id == item.id }),
              displayValues.indices.contains(index) else {
            return item.value
        }
        return displayValues[index]
    }

    /// Extracts the non-numeric suffix from a value string.
    /// "60 kg" → " kg", "165 cm" → " cm", "20" → ""
    private func numericUnit(from value: String) -> String {
        var s = value
        while !s.isEmpty && (s.first!.isNumber || s.first == ".") {
            s = String(s.dropFirst())
        }
        return s
    }

    /// Drives numeric display slots from 0 → target over ~0.8s using a Timer.
    /// Mirrors the ProgressScreenView timer pattern for guaranteed per-tick re-renders.
    private func startCounterAnimation() {
        let duration = 0.8
        let steps    = 60
        let interval = duration / Double(steps)

        let targets: [(index: Int, target: Double, unit: String)] = items.enumerated().compactMap { i, item in
            let scanner = Scanner(string: item.value)
            guard let number = scanner.scanDouble() else { return nil }
            return (i, number, numericUnit(from: item.value))
        }

        var step = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            step += 1
            let progress = Double(step) / Double(steps)
            for (index, target, unit) in targets {
                let current = Int((progress * target).rounded())
                self.displayValues[index] = "\(current)\(unit)"
            }
            if step >= steps {
                for (index, target, unit) in targets {
                    self.displayValues[index] = "\(Int(target))\(unit)"
                }
                timer.invalidate()
            }
        }
    }

    // MARK: - Animation Sequence

    private func startAnimationSequence() {
        // 0.0s: Title slides up + card box fades in
        withAnimation(.easeOut(duration: 0.5)) {
            titleOpacity = 1
            titleOffset = 0
        }
       
        // 0.3s: Subtitle fades in + labels slide up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.4)) {
                subtitleOpacity = 1
                subtitleOffset = 0
            }
            withAnimation(.easeOut(duration: 0.9)) {
                labelsOpacity = 1
                labelsOffset = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.6)) {
                cardOpacity = 1
            }
        }

        // Alternating left-right item animations with staggered timing
        for (index, _) in items.enumerated() {
            let isLeftSlide = index % 2 == 0
            let initialOffset: CGFloat = isLeftSlide ? -50 : 50
            let labelDelay = 0.4 + (Double(index) * 0.2)
            let valueDelay = labelDelay + 0.1  // Value appears 0.1s after label
            
            // Animate label
            DispatchQueue.main.asyncAfter(deadline: .now() + labelDelay) {
                self.labelOffsets[index] = initialOffset
                self.labelOpacities[index] = 0
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.labelOffsets[index] = 0
                    self.labelOpacities[index] = 1
                }
            }

            // Animate value (after label)
            DispatchQueue.main.asyncAfter(deadline: .now() + valueDelay) {
                self.valueOffsets[index] = initialOffset
                self.valueOpacities[index] = 0
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.valueOffsets[index] = 0
                    self.valueOpacities[index] = 1
                }
            }
        }

        // Values fade in + numeric counter starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 1)) {
                valuesOpacity = 1
            }
            startCounterAnimation()
        }

        // Button slides up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeOut(duration: 0.5)) {
                buttonOpacity = 1
                buttonOffset = 0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BiologicalSummaryView(
        onComplete: {},
        items: [
            SummaryItem(label: "Name", value: "Joana"),
            SummaryItem(label: "Age", value: "20"),
            SummaryItem(label: "Biological Sex", value: "Female"),
            SummaryItem(label: "Weight", value: "60 kg"),
            SummaryItem(label: "Height", value: "165 cm"),
            SummaryItem(label: "Location", value: "South Africa"),
        ]
    )
}
