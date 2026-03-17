import SwiftUI

// MARK: - Constants
private let graphHeight: CGFloat = 200
private let startYRatio: CGFloat = 0.95 // shared start y-position ratio

// MARK: - ThethaFeedLine
/// Green "With ThethaFeed" line — starts at shared origin, curves upward (good outcome).
struct ThethaFeedLine: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: 0, y: h * startYRatio))
        p.addCurve(to: CGPoint(x: w * 0.33, y: h * 0.34),
                   control1: CGPoint(x: w * 0.11, y: h * startYRatio),
                   control2: CGPoint(x: w * 0.22, y: h * 0.40))
        p.addCurve(to: CGPoint(x: w * 0.66, y: h * 0.20),
                   control1: CGPoint(x: w * 0.44, y: h * 0.28),
                   control2: CGPoint(x: w * 0.55, y: h * 0.23))
        p.addCurve(to: CGPoint(x: w, y: h * 0.10),
                   control1: CGPoint(x: w * 0.78, y: h * 0.17),
                   control2: CGPoint(x: w * 0.89, y: h * 0.12))
        return p
    }
}

// MARK: - TraditionalLine
/// Red "Traditional / no-app" line — starts at same origin, dips down and plateaus low (failure pattern).
struct TraditionalLine: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: 0, y: h * startYRatio))
        p.addCurve(to: CGPoint(x: w * 0.28, y: h * 0.72),
                   control1: CGPoint(x: w * 0.09, y: h * startYRatio),
                   control2: CGPoint(x: w * 0.18, y: h * 0.67))
        p.addCurve(to: CGPoint(x: w * 0.58, y: h * 0.78),
                   control1: CGPoint(x: w * 0.38, y: h * 0.77),
                   control2: CGPoint(x: w * 0.48, y: h * 0.80))
        p.addCurve(to: CGPoint(x: w, y: h * 0.80),
                   control1: CGPoint(x: w * 0.70, y: h * 0.76),
                   control2: CGPoint(x: w * 0.86, y: h * 0.79))
        return p
    }
}

// MARK: - ThethaFeedDot

/// Animated dot that travels along ThethaFeedLine using arc-length parameterization.
/// Using Shape + animatableData ensures the dot position is computed every animation frame
/// from the trimmed path endpoint — guaranteed to match the drawn line.
struct ThethaFeedDot: Shape {
    var progress: CGFloat
    var radius: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard progress > 0 else { return Path() }
        let trimmed = ThethaFeedLine().path(in: rect).trimmedPath(from: 0, to: min(1, progress))
        let c = trimmed.cgPath.currentPoint
        var p = Path()
        p.addEllipse(in: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2))
        return p
    }
}

// MARK: - TraditionalDot

/// Animated dot that travels along TraditionalLine using arc-length parameterization.
struct TraditionalDot: Shape {
    var progress: CGFloat
    var radius: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard progress > 0 else { return Path() }
        let trimmed = TraditionalLine().path(in: rect).trimmedPath(from: 0, to: min(1, progress))
        let c = trimmed.cgPath.currentPoint
        var p = Path()
        p.addEllipse(in: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2))
        return p
    }
}

// MARK: - FailurePatternView

/**
 * FailurePattern Component
 *
 * Animated comparison line chart showing the gap between ThethaFeed users
 * and people who follow traditional approaches.
 *
 * Animation phases:
 * - Phase 1 (0–0.7s):   Title crossfades / slides in from slight offset above
 * - Phase 2 (0.7–1.1s): White chart card fades in; start circle appears
 * - Phase 3 (1.1–3.1s): Both lines draw left-to-right using trim(from:to:);
 *                         vertical playhead bar sweeps in sync
 * - Phase 4 (3.1–3.7s): Gap fill, x-axis labels, legend badge, and endpoint
 *                         circles all animate in together
 * - Phase 5 (3.7–4.3s): Persuasive stat text fades in below the card
 * - Phase 6 (4.3–5.0s): "Continue" button scales up and fades in
 */
struct FailurePatternView: View {
    var onComplete: (() -> Void)?

    // MARK: - Animation State

    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = -18

    @State private var cardOpacity: Double = 0

    @State private var lineProgress: CGFloat = 0   // drives line trim and travelling dots

    @State private var gapFillOpacity: Double = 0
    @State private var labelsOpacity: Double = 0

    @State private var statOpacity: Double = 0
    @State private var statOffset: CGFloat = 20   // ADDED: slide-up start offset for stat text

    @State private var buttonOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.96

    @State private var screenOpacity: Double = 1.0

    // MARK: - Body

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
                // Phase 1: Title at top
                VStack(spacing: 6) {
                    Text("Failure Pattern")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(AppColors.text)
                    Text("See where most people fall off")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textMuted)
                }
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
                .padding(.top, 64)
                .padding(.horizontal, 32)

                Spacer()

                // Phase 2–4: Chart card
                chartCard
                    .opacity(cardOpacity)
                    .padding(.horizontal, 22)

                // Phase 5: Stat text
                Text("This is where most people fall off")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                    .opacity(statOpacity)
                    .offset(y: statOffset)   // ADDED: slide-up offset for entrance animation


                Spacer()

                // Phase 6: Continue button
                PrimaryButton(title: "Continue", action: handleNextPress)
                    .opacity(buttonOpacity)
                    .scaleEffect(buttonScale)
                    .padding(.horizontal, 34)
                    .padding(.bottom, 40)
            }
        }
        .opacity(screenOpacity)
        .onAppear { startAnimationSequence() }
    }

    // MARK: - Chart Card

    private var chartCard: some View {
        VStack(spacing: 12) {
            GeometryReader { geo in
                let gw = geo.size.width

                ZStack {
                    // Dotted horizontal gridlines
                    ForEach([0.25, 0.50, 0.75], id: \.self) { ratio in
                        Path { path in
                            let y = graphHeight * ratio
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: gw, y: y))
                        }
                        .stroke(Color.gray.opacity(0.18),
                                style: StrokeStyle(lineWidth: 1, dash: [4, 5]))
                        .frame(width: gw, height: graphHeight)
                    }
                    // ThethaFeed line (green, goes UP)
                    ThethaFeedLine()
                        .trim(from: 0, to: lineProgress)
                        .stroke(AppColors.primary,
                                style: StrokeStyle(lineWidth: 2.5,
                                                   lineCap: .round,
                                                   lineJoin: .round))
                        .frame(width: gw, height: graphHeight)

                    // Traditional line (red, dips LOW)
                    TraditionalLine()
                        .trim(from: 0, to: lineProgress)
                        .stroke(Color(hex: "#EF4444"),
                                style: StrokeStyle(lineWidth: 2.5,
                                                   lineCap: .round,
                                                   lineJoin: .round))
                        .frame(width: gw, height: graphHeight)

                    // Shared start-point circle
                    Circle()
                        .strokeBorder(AppColors.textMuted.opacity(0.45), lineWidth: 1.5)
                        .background(Circle().fill(Color.white))
                        .frame(width: 9, height: 9)
                        .position(x: 4.5, y: graphHeight * startYRatio)

                    // Green travelling dot — outer ring + inner white, tracks ThethaFeedLine exactly
                    ThethaFeedDot(progress: lineProgress, radius: 5.5)
                        .fill(AppColors.primary)
                        .frame(width: gw, height: graphHeight)
                    ThethaFeedDot(progress: lineProgress, radius: 2.5)
                        .fill(Color.white)
                        .frame(width: gw, height: graphHeight)

                    // Red travelling dot — outer ring + inner white, tracks TraditionalLine exactly
                    TraditionalDot(progress: lineProgress, radius: 5.5)
                        .fill(Color(hex: "#EF4444"))
                        .frame(width: gw, height: graphHeight)
                    TraditionalDot(progress: lineProgress, radius: 2.5)
                        .fill(Color.white)
                        .frame(width: gw, height: graphHeight)
                }
                .frame(width: gw, height: graphHeight)
            }
            .frame(height: graphHeight)

            // X-axis month labels
            HStack(spacing: 0) {
                ForEach(["M1", "M2", "M3", "M4", "M5", "M6"], id: \.self) { label in
                    Text(label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            .opacity(labelsOpacity)

            Divider()
                .opacity(0.6)

            // Legend
            HStack(spacing: 24) {
                legendItem(color: AppColors.primary, label: "With StackAI")
                legendItem(color: Color(hex: "#EF4444"), label: "Without StackAI")
            }
            .opacity(labelsOpacity)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.07), radius: 20, x: 0, y: 6)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 7) {
            Capsule()
                .fill(color)
                .frame(width: 18, height: 3)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.textMuted)
        }
    }

    // MARK: - Animation Sequence

    private func startAnimationSequence() {
        // Phase 1: Title crossfade / slide up (0–0.5s)
        withAnimation(.easeOut(duration: 0.5)) {
            titleOpacity = 1
            titleOffset = 0
        }

        // Phase 2: Card fades in (0.7–1.1s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardOpacity = 1
            }
        }

        // Phase 3: Lines draw left-to-right + playhead sweeps in sync (1.1–3.1s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           withAnimation(.easeOut(duration: 1.0)) {
                lineProgress = 1
            }
        }

        // Phase 4: Gap fill + labels + legend (3.1–3.7s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.55)) {
                gapFillOpacity = 1
                labelsOpacity = 1
            }
        }

        // Phase 5: Stat text slides up + fades in (3.7–4.3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {   // CHANGED: easeIn → easeOut (better for slide-up)
                statOpacity = 1
                statOffset = 0   // ADDED: animate to resting position
            }
        }

        // Phase 6: Continue button (4.3–5.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeOut(duration: 0.7)) {
                buttonOpacity = 1
                buttonScale = 1
            }
        }
    }

    // MARK: - Actions

    private func handleNextPress() {
        withAnimation(.easeIn(duration: 0.3)) {
            screenOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete?()
        }
    }
}

// MARK: - Preview

#Preview {
    FailurePatternView(onComplete: {})
}
