import SwiftUI

/// Interactive gauge-based question component for Risk Tolerance and Motivation
struct SliderChoiceView: View {
    let onComplete: () -> Void
    let onBack: () -> Void
    let currentStep: Int
    let totalSteps: Int

    static let screensCount = 2

    @State private var screenIndex: Int = 0
    @State private var sliderValues: [Double] = [50, 50]
    @State private var contentOpacity: Double = 1.0

    private let questions: [(id: String, category: String, question: String)] = [
        (id: "risk-tolerance", category: "Risk Tolerance", question: "How much risk are you willing to take?"),
        (id: "motivation", category: "Motivation", question: "How motivated are you to start?"),
    ]

    private var actualStep: Int {
        currentStep + screenIndex
    }

    private var currentSliderValue: Double {
        sliderValues[screenIndex]
    }

    /// Maps slider value (0-100) to gauge needle angle (-90 to +90)
    private var needleAngle: Double {
        -90.0 + (currentSliderValue / 100.0) * 180.0
    }

    private var currentLabel: String {
        let value = currentSliderValue
        switch value {
        case 0..<20: return "Very Low"
        case 20..<45: return "Low"
        case 45..<65: return "Moderate"
        case 65..<80: return "High"
        default: return "Very High"
        }
    }

    private var currentLabelColor: Color {
        let value = currentSliderValue
        switch value {
        case 0..<20: return .blue
        case 20..<45: return AppColors.primary
        case 45..<65: return .yellow
        case 65..<80: return .orange
        default: return .red
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            LinearGradient(
                colors: [AppColors.primary.opacity(0.18), Color.clear],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.35)
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                ProgressBarView(current: actualStep, total: totalSteps)
                    .padding(.top, 60)
                    .padding(.horizontal, 24)

                // Header
                HStack {
                    Button(action: handleBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Question content
                VStack(alignment: .leading, spacing: 8) {
                    Text(questions[screenIndex].category)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primary)

                    Text(questions[screenIndex].question)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .opacity(contentOpacity)

                Spacer()

                // Gauge slider area
                VStack(spacing: 40) {
                   

                    // Interactive gauge
                    GaugeView(needleAngle: needleAngle)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    handleGaugeDrag(value: value)
                                }
                        )
                        .animation(.easeOut(duration: 0.1), value: currentSliderValue)
                    // Current label
                    Text(currentLabel)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(currentLabelColor)
                        .padding(.bottom, 24)

                    
                   
                }
                .opacity(contentOpacity)

                Spacer()

                // NEXT button
                PrimaryButton(title: "NEXT", action: handleNext)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Gauge Drag Handling

    /// Converts a drag gesture location into a slider value (0-100)
    /// by calculating the angle from the gesture point to the gauge center.
    private func handleGaugeDrag(value: DragGesture.Value) {
        // The GaugeView is framed at gaugeSizeL (107 x 107)
        // The gauge center is at (107/2, 107/2) = (53.5, 53.5)
        let gaugeCenter = CGPoint(x: 107.0 / 2.0, y: 107.0 / 2.0)

        // Calculate delta from center
        let dx = value.location.x - gaugeCenter.x
        let dy = value.location.y - gaugeCenter.y

        // Calculate angle using atan2 (0 = right, positive = clockwise in screen coords)
        // We need to map: left side (-90°) = 0%, top (0°) = 50%, right side (+90°) = 100%
        // atan2 gives angle from positive x-axis
        let angle = atan2(dx, -dy) // angle from top (12 o'clock), clockwise positive
        let angleDegrees = angle * 180.0 / .pi

        // Clamp to -90...+90 range (the gauge's semicircle)
        let clampedDegrees = min(max(angleDegrees, -90.0), 90.0)

        // Map -90...+90 to 0...100
        let percentage = (clampedDegrees + 90.0) / 180.0 * 100.0
        sliderValues[screenIndex] = percentage
    }

    // MARK: - Navigation

    private func handleNext() {
        if screenIndex < questions.count - 1 {
            withAnimation(.easeOut(duration: 0.15)) { contentOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                screenIndex += 1
                withAnimation(.easeIn(duration: 0.3)) { contentOpacity = 1 }
            }
        } else {
            onComplete()
        }
    }

    private func handleBack() {
        if screenIndex > 0 {
            withAnimation(.easeOut(duration: 0.15)) { contentOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                screenIndex -= 1
                withAnimation(.easeIn(duration: 0.3)) { contentOpacity = 1 }
            }
        } else {
            onBack()
        }
    }
}

#Preview {
    SliderChoiceView(
        onComplete: {},
        onBack: {},
        currentStep: 5,
        totalSteps: 10
    )
}
