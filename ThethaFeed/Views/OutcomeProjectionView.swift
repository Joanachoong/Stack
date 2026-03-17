import SwiftUI

// MARK: - RadialRingView

private struct RadialRingView: View {
    @Binding var progress: CGFloat
    var displayValue: Int
    var color: Color

    private let size: CGFloat = 90
    private let lineWidth: CGFloat = 10

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(AppColors.progressTrack, lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Fill ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.primaryMuted, color],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Center score
            VStack(spacing: 1) {
                Text("\(displayValue)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.text)
                Text("/100")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.textMuted)
            }
        }
    }
}

// MARK: - OutcomeProjectionView

/// Animated performance dashboard with three radial ring metrics
struct OutcomeProjectionView: View {
    let onComplete: () -> Void

    @State private var headlineOpacity: Double = 0
    @State private var subtextOpacity: Double = 0
    @State private var dashboardOpacity: Double = 0
    @State private var recoveryProgress: CGFloat = 0
    @State private var performanceProgress: CGFloat = 0
    @State private var consistencyProgress: CGFloat = 0
    @State private var recoveryDisplay: Int = 0
    @State private var performanceDisplay: Int = 0
    @State private var consistencyDisplay: Int = 0
    @State private var buttonOpacity: Double = 0
    @State private var fadeOut: Double = 1.0

    private let metrics: [(name: String, target: Int, color: Color)] = [
        ("Recovery", 87, AppColors.primary),
        ("Performance", 72, AppColors.primary),
        ("Consistency", 72, AppColors.primary),
    ]

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
                Spacer()

                // Headline
                VStack(spacing: 12) {
                    Text("Outcome Projection")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .opacity(headlineOpacity)

                    Text("Based on your inputs, here's how\nwe predict you'll perform in each category:")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textMuted)
                        .multilineTextAlignment(.center)
                        .opacity(subtextOpacity)
                }
                .padding(.bottom, 40)

                // Dashboard — three radial rings
                HStack(spacing: 20) {
                    ringCell(index: 0)
                    ringCell(index: 1)
                    ringCell(index: 2)
                }
                .padding(24)
                .background(Color.white.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .opacity(dashboardOpacity)

                Spacer()

                // Continue button
                PrimaryButton(title: "CONTINUE") {
                    withAnimation(.easeOut(duration: 0.3)) { fadeOut = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onComplete() }
                }
                .opacity(buttonOpacity)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .opacity(fadeOut)
        }
        .onAppear { animateSequence() }
    }

    @ViewBuilder
    private func ringCell(index: Int) -> some View {
        let metric = metrics[index]
        VStack(spacing: 10) {
            RadialRingView(
                progress: progressBinding(for: index),
                displayValue: displayValue(for: index),
                color: metric.color
            )
            Text(metric.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
    }

    private func progressBinding(for index: Int) -> Binding<CGFloat> {
        switch index {
        case 0: return $recoveryProgress
        case 1: return $performanceProgress
        default: return $consistencyProgress
        }
    }

    private func displayValue(for index: Int) -> Int {
        switch index {
        case 0: return recoveryDisplay
        case 1: return performanceDisplay
        default: return consistencyDisplay
        }
    }

    private func animateSequence() {
        // Phase 1: Headlines
        withAnimation(.easeOut(duration: 0.3)) { headlineOpacity = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.6)) { subtextOpacity = 1 }
        }

        // Phase 2: Dashboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeOut(duration: 0.8)) { dashboardOpacity = 1 }
        }

        // Phase 3: Rings fill sequentially
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            animateRing(target: 87, duration: 0.9,
                updateProgress: { recoveryProgress = $0 },
                updateDisplay: { recoveryDisplay = $0 })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            animateRing(target: 72, duration: 0.9,
                updateProgress: { performanceProgress = $0 },
                updateDisplay: { performanceDisplay = $0 })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            animateRing(target: 72, duration: 0.9,
                updateProgress: { consistencyProgress = $0 },
                updateDisplay: { consistencyDisplay = $0 })
        }

        // Phase 4: Button
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeOut(duration: 0.7)) { buttonOpacity = 1 }
        }
    }

    private func animateRing(target: Int, duration: Double,
                             updateProgress: @escaping (CGFloat) -> Void,
                             updateDisplay: @escaping (Int) -> Void) {
        withAnimation(.easeOut(duration: duration)) {
            updateProgress(CGFloat(target) / 100.0)
        }
        let steps = target
        let interval = duration / Double(steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                updateDisplay(i)
            }
        }
    }
}

#Preview {
    OutcomeProjectionView(onComplete: {})
}
