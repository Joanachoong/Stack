import SwiftUI

/// Circular progress ring screen shown during personalized analysis.
///
/// Displays an animated circular progress ring that fills from 0% to 100%
/// over 5 seconds. Once complete, calls the onComplete callback to advance
/// to the next screen.
///
/// Converted from components/ProgressScreen.tsx
struct ProgressScreenView: View {
    var onComplete: () -> Void

    private let ringSize: CGFloat = 220
    private let strokeWidth: CGFloat = 12
    private let dotSize: CGFloat = 24
    private let animationDuration: Double = 5.0

    private var radius: CGFloat {
        (ringSize - strokeWidth) / 2
    }

    @State private var progress: CGFloat = 0.0
    @State private var displayPercentage: Int = 0

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            LinearGradient(
                colors: [AppColors.primary.opacity(0.18), Color.clear],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.35)
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Progress ring
                ZStack {
                    // Glow behind ring
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: ringSize, height: ringSize)
                        .shadow(color: AppColors.primary.opacity(0.5), radius: 40)

                    // Background track circle
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: strokeWidth)
                        .frame(width: ringSize, height: ringSize)

                    // Progress arc with gradient
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    AppColors.primaryMuted,
                                    AppColors.primary,
                                    AppColors.primary
                                ]),
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            ),
                            style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                        )
                        .frame(width: ringSize, height: ringSize)
                        .rotationEffect(.degrees(-90))

                    // Percentage text in center
                    Text("\(displayPercentage)%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.primary)

                    // Indicator dot that follows the progress
                    Circle()
                        .fill(AppColors.primaryMuted)
                        .frame(width: dotSize, height: dotSize)
                        .shadow(color: AppColors.primary.opacity(0.6), radius: 10)
                        .offset(
                            x: cos(CGFloat(displayPercentage) / 100.0 * 2 * .pi - .pi / 2) * radius,
                            y: sin(CGFloat(displayPercentage) / 100.0 * 2 * .pi - .pi / 2) * radius
                        )
                }
                .frame(width: ringSize + 40, height: ringSize + 40)

                // Loading text
                Text("Personalized analysis in progress..")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.text)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            startAnimation()
        }
    }

    /// Starts the progress animation from 0 to 100% over the animation duration.
    /// Uses a Timer to update the display percentage for smooth text updates,
    /// and a SwiftUI animation for the ring progress.
    private func startAnimation() {
        // Animate the ring progress
        withAnimation(.linear(duration: animationDuration)) {
            progress = 1.0
        }

        // Update the percentage display using a timer
        let interval: TimeInterval = animationDuration / 100.0
        var currentPercent = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            currentPercent += 1
            displayPercentage = currentPercent

            if currentPercent >= 100 {
                timer.invalidate()
                // Delay before calling onComplete to let user see 100%
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    ProgressScreenView(onComplete: {})
}
