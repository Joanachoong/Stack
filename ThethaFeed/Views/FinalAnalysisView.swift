import SwiftUI

/// Animated loading/analysis screen with two phases: loading bar and results ready
struct FinalAnalysisView: View {
    let onComplete: () -> Void
    var duration: Double = 4.0

    @State private var phase: AnalysisPhase = .loading
    @State private var loadingProgress: CGFloat = 0
    @State private var loadingOpacity: Double = 1.0
    @State private var resultsOpacity: Double = 0
    @State private var fadeOut: Double = 1.0

    enum AnalysisPhase {
        case loading, results
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
                Spacer()

                if phase == .loading {
                    // Loading phase
                    VStack(spacing: 24) {
                        Text("Analysing your result")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)

                        Text("Please wait while we are processing")
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.textMuted)

                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColors.progressTrack)
                                    .frame(height: 16)

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white, AppColors.primary, AppColors.primaryMuted, AppColors.textMuted],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * loadingProgress, height: 16)
                                    .animation(.linear(duration: duration), value: loadingProgress)
                            }
                        }
                        .frame(height: 16)
                        .padding(.horizontal, 40)

                        Text("\(Int(loadingProgress * 100))%")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textMuted)
                    }
                    .opacity(loadingOpacity)

                } else {
                    // Results ready phase
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primary)

                        Text("Your results are ready.")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)

                        PrimaryButton(title: "Click Here to see result") {
                            withAnimation(.easeOut(duration: 0.3)) { fadeOut = 0 }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onComplete() }
                        }
                        .padding(.horizontal, 24)
                    }
                    .opacity(resultsOpacity)
                }

                Spacer()
            }
            .opacity(fadeOut)
        }
        .onAppear {
            startLoading()
        }
    }

    private func startLoading() {
        // Animate progress bar
        withAnimation(.linear(duration: duration)) {
            loadingProgress = 1.0
        }

        // Update percentage counter
        let steps = 100
        let interval = duration / Double(steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                loadingProgress = CGFloat(i) / 100.0
            }
        }

        // Transition to results
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                loadingOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                phase = .results
                withAnimation(.easeIn(duration: 0.5)) {
                    resultsOpacity = 1
                }
            }
        }
    }
}

#Preview {
    FinalAnalysisView(onComplete: {})
}
