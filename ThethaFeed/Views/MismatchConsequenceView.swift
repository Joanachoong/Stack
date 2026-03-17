import SwiftUI

// MARK: - Constants
private let mismatchGraphHeight: CGFloat = 200
private let mismatchStartYRatio: CGFloat = 0.85   // shared start y for both mismatch lines

// MARK: - Expected Line Path

/// Shape: ideal upward progress curve. Coordinate ratios preserved from original.
struct ExpectedLinePath: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height   // CHANGED: removed width/height init params; use rect
        var path = Path()
        path.move(to: CGPoint(x: 0, y: h * 0.85))
        path.addCurve(
            to: CGPoint(x: w * 0.35, y: h * 0.50),
            control1: CGPoint(x: w * 0.12, y: h * 0.70),
            control2: CGPoint(x: w * 0.25, y: h * 0.50)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.65, y: h * 0.25),
            control1: CGPoint(x: w * 0.45, y: h * 0.50),
            control2: CGPoint(x: w * 0.55, y: h * 0.30)
        )
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.10),
            control1: CGPoint(x: w * 0.75, y: h * 0.20),
            control2: CGPoint(x: w * 0.90, y: h * 0.12)
        )
        return path
    }
}

// MARK: - Actual Line Path

/// Shape: actual (stalled) progress curve. Coordinate ratios preserved from original.
struct MismatchActualPath: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height   // CHANGED: removed width/height init params; use rect
        var path = Path()
        path.move(to: CGPoint(x: 0, y: h * 0.85))
        path.addCurve(
            to: CGPoint(x: w * 0.30, y: h * 0.55),
            control1: CGPoint(x: w * 0.12, y: h * 0.70),
            control2: CGPoint(x: w * 0.22, y: h * 0.50)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.60),
            control1: CGPoint(x: w * 0.38, y: h * 0.60),
            control2: CGPoint(x: w * 0.48, y: h * 0.65)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.80, y: h * 0.55),
            control1: CGPoint(x: w * 0.62, y: h * 0.55),
            control2: CGPoint(x: w * 0.72, y: h * 0.50)
        )
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.75),
            control1: CGPoint(x: w * 0.88, y: h * 0.60),
            control2: CGPoint(x: w * 0.95, y: h * 0.80)
        )
        return path
    }
}

// MARK: - ExpectedDot

/// Animated dot that travels along ExpectedLinePath using arc-length parameterization.
struct ExpectedDot: Shape {
    var progress: CGFloat
    var radius: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard progress > 0 else { return Path() }
        let trimmed = ExpectedLinePath().path(in: rect).trimmedPath(from: 0, to: min(1, progress))
        let c = trimmed.cgPath.currentPoint
        var p = Path()
        p.addEllipse(in: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2))
        return p
    }
}

// MARK: - ActualDot

/// Animated dot that travels along MismatchActualPath using arc-length parameterization.
struct ActualDot: Shape {
    var progress: CGFloat
    var radius: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard progress > 0 else { return Path() }
        let trimmed = MismatchActualPath().path(in: rect).trimmedPath(from: 0, to: min(1, progress))
        let c = trimmed.cgPath.currentPoint
        var p = Path()
        p.addEllipse(in: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2))
        return p
    }
}

// MARK: - MismatchConsequenceView

/// Animated graph showing consequences of mismatched training and protocols.
/// Animation system adopted from FailurePatternView: single lineProgress, travelling dots,
/// GeometryReader chart width, white card, phased timing.
struct MismatchConsequenceView: View {
    let onComplete: () -> Void

    // MARK: - Animation State

    @State private var titleOpacity: Double = 0           // RENAMED from headlineOpacity
    @State private var titleOffset: CGFloat = -18         // CHANGED: slide from above (was 20/below)

    @State private var cardOpacity: Double = 0            // RENAMED from dashboardOpacity

    @State private var lineProgress: CGFloat = 0          // ADDED: single shared progress for both lines

    @State private var labelsOpacity: Double = 0          // ADDED: separate phase for labels + legend

    @State private var buttonOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.96        // CHANGED from 0.9 → 0.96 to match FailurePatternView

    @State private var screenOpacity: Double = 1.0        // ADDED: replaces fadeOut

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
                // Phase 1: Title at top — slides down from above + fades in
                Text("Mismatched training\nand protocols lead to\nstalled progress.")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
                    .padding(.top, 64)
                    .padding(.horizontal, 24)

                Spacer()

                // Phase 2–4: Chart card
                chartCard
                    .opacity(cardOpacity)
                    .padding(.horizontal, 22)

                Spacer()

                // Phase 5: Continue button
                PrimaryButton(title: "NEXT", action: handleNextPress)
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
                let gw = geo.size.width   // ADDED: dynamic width via GeometryReader

                ZStack {
                    // Dotted horizontal gridlines
                    ForEach([0.25, 0.50, 0.75], id: \.self) { ratio in
                        Path { path in
                            let y = mismatchGraphHeight * ratio
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: gw, y: y))
                        }
                        .stroke(Color.gray.opacity(0.18),
                                style: StrokeStyle(lineWidth: 1, dash: [4, 5]))
                        .frame(width: gw, height: mismatchGraphHeight)
                    }

                    // Expected line (green, goes UP)
                    ExpectedLinePath()
                        .trim(from: 0, to: lineProgress)
                        .stroke(AppColors.primary,
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .frame(width: gw, height: mismatchGraphHeight)

                    // Actual line (red, stalls)
                    MismatchActualPath()
                        .trim(from: 0, to: lineProgress)
                        .stroke(Color(hex: "EF4444"),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .frame(width: gw, height: mismatchGraphHeight)

                    // Shared start-point circle
                    Circle()
                        .strokeBorder(AppColors.textMuted.opacity(0.45), lineWidth: 1.5)
                        .background(Circle().fill(Color.white))
                        .frame(width: 9, height: 9)
                        .position(x: 4.5, y: mismatchGraphHeight * mismatchStartYRatio)

                    // Green travelling dot — outer ring + inner white, tracks ExpectedLinePath exactly
                    ExpectedDot(progress: lineProgress, radius: 5.5)
                        .fill(AppColors.primary)
                        .frame(width: gw, height: mismatchGraphHeight)
                    ExpectedDot(progress: lineProgress, radius: 2.5)
                        .fill(Color.white)
                        .frame(width: gw, height: mismatchGraphHeight)

                    // Red travelling dot — outer ring + inner white, tracks MismatchActualPath exactly
                    ActualDot(progress: lineProgress, radius: 5.5)
                        .fill(Color(hex: "EF4444"))
                        .frame(width: gw, height: mismatchGraphHeight)
                    ActualDot(progress: lineProgress, radius: 2.5)
                        .fill(Color.white)
                        .frame(width: gw, height: mismatchGraphHeight)
                }
                .frame(width: gw, height: mismatchGraphHeight)
            }
            .frame(height: mismatchGraphHeight)

            // X-axis day labels — kept from original
            HStack(spacing: 0) {
                ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { _, day in
                    Text(day)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            .opacity(labelsOpacity)

            Divider()
                .opacity(0.6)

            // Legend — kept from original
            HStack(spacing: 24) {
                legendItem(color: AppColors.primary, label: "Expected Progress")
                legendItem(color: Color(hex: "EF4444"), label: "Actual Progress")
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
        // Phase 1: Title slides down + fades in (0–0.5s)
        withAnimation(.easeOut(duration: 0.5)) {
            titleOpacity = 1
            titleOffset = 0
        }

        // Phase 2: Card fades in (0.7s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardOpacity = 1
            }
        }

        // Phase 3: Both lines draw simultaneously + dots travel (1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 1.0)) {
                lineProgress = 1   // ADDED: single progress drives both lines + dots
            }
        }

        // Phase 4: Labels + legend fade in (2.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.55)) {
                labelsOpacity = 1   // ADDED: separate phase for labels
            }
        }

        // Phase 5: Button scales + fades in (3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.7)) {
                buttonOpacity = 1
                buttonScale = 1
            }
        }
    }

    // MARK: - Actions

    private func handleNextPress() {
        withAnimation(.easeIn(duration: 0.3)) {
            screenOpacity = 0   // ADDED: replaces fadeOut pattern
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onComplete() }
    }
}

// MARK: - Preview

#Preview {
    MismatchConsequenceView(onComplete: {})
}
