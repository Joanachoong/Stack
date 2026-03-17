import SwiftUI

// MARK: - SplashScreenView
// Converted from components/SplashScreen.tsx (185 lines)
// Displays the app splash screen with animated logo, title, and loading dots
// Auto-dismisses after 2.5 seconds calling onFinish

// MARK: - ThetaIcon Shape
// SVG path: "M35 5C18.4315 5 5 18.4315 5 35C5 51.5685 18.4315 65 35 65C51.5685 65 65 51.5685 65 35C65 18.4315 51.5685 5 35 5ZM35 55C23.9543 55 15 46.0457 15 35C15 23.9543 23.9543 15 35 15C46.0457 15 55 23.9543 55 35C55 46.0457 46.0457 55 35 55ZM20 35H50"
struct ThetaIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scaleX = rect.width / 70.0
        let scaleY = rect.height / 70.0

        // Outer circle: M35 5C18.4315 5 5 18.4315 5 35C5 51.5685 18.4315 65 35 65C51.5685 65 65 51.5685 65 35C65 18.4315 51.5685 5 35 5Z
        path.move(to: CGPoint(x: 35 * scaleX, y: 5 * scaleY))
        path.addCurve(
            to: CGPoint(x: 5 * scaleX, y: 35 * scaleY),
            control1: CGPoint(x: 18.4315 * scaleX, y: 5 * scaleY),
            control2: CGPoint(x: 5 * scaleX, y: 18.4315 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 35 * scaleX, y: 65 * scaleY),
            control1: CGPoint(x: 5 * scaleX, y: 51.5685 * scaleY),
            control2: CGPoint(x: 18.4315 * scaleX, y: 65 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 65 * scaleX, y: 35 * scaleY),
            control1: CGPoint(x: 51.5685 * scaleX, y: 65 * scaleY),
            control2: CGPoint(x: 65 * scaleX, y: 51.5685 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 35 * scaleX, y: 5 * scaleY),
            control1: CGPoint(x: 65 * scaleX, y: 18.4315 * scaleY),
            control2: CGPoint(x: 51.5685 * scaleX, y: 5 * scaleY)
        )
        path.closeSubpath()

        // Inner circle (counter-clockwise to create hole):
        // M35 55C23.9543 55 15 46.0457 15 35C15 23.9543 23.9543 15 35 15C46.0457 15 55 23.9543 55 35C55 46.0457 46.0457 55 35 55Z
        path.move(to: CGPoint(x: 35 * scaleX, y: 55 * scaleY))
        path.addCurve(
            to: CGPoint(x: 15 * scaleX, y: 35 * scaleY),
            control1: CGPoint(x: 23.9543 * scaleX, y: 55 * scaleY),
            control2: CGPoint(x: 15 * scaleX, y: 46.0457 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 35 * scaleX, y: 15 * scaleY),
            control1: CGPoint(x: 15 * scaleX, y: 23.9543 * scaleY),
            control2: CGPoint(x: 23.9543 * scaleX, y: 15 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 55 * scaleX, y: 35 * scaleY),
            control1: CGPoint(x: 46.0457 * scaleX, y: 15 * scaleY),
            control2: CGPoint(x: 55 * scaleX, y: 23.9543 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 35 * scaleX, y: 55 * scaleY),
            control1: CGPoint(x: 55 * scaleX, y: 46.0457 * scaleY),
            control2: CGPoint(x: 46.0457 * scaleX, y: 55 * scaleY)
        )
        path.closeSubpath()

        // Horizontal bar: M20 35H50
        // Rendered as a thin rectangle for visibility
        let barHeight: CGFloat = 3 * scaleY
        path.addRect(CGRect(
            x: 20 * scaleX,
            y: 35 * scaleY - barHeight / 2,
            width: 30 * scaleX,
            height: barHeight
        ))

        return path
    }
}

// MARK: - ThetaIconView
// Renders the Theta icon at a given size with fill color
struct ThetaIconView: View {
    var size: CGFloat = 70
    var fillColor: Color = .black

    var body: some View {
        ThetaIconShape()
            .fill(fillColor, style: FillStyle(eoFill: true))
            .frame(width: size, height: size)
    }
}

// MARK: - SplashScreenView
struct SplashScreenView: View {
    // Callback when splash screen finishes
    let onFinish: () -> Void

    // Fade in + scale animation on appear
    @State private var fadeOpacity: Double = 0
    @State private var contentScale: CGFloat = 0.8

    // 3 loading dots with staggered opacity animation
    @State private var dot1Opacity: Double = 0.3
    @State private var dot2Opacity: Double = 0.3
    @State private var dot3Opacity: Double = 0.3

    // Controls the fade-out before dismiss
    @State private var dismissOpacity: Double = 1.0

    // Timer reference for cleanup
    @State private var dismissTimer: Timer?

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Green glow accent at top
            LinearGradient(
                colors: [
                    AppColors.primary.opacity(0.20),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.35)
            )
            .ignoresSafeArea()

            // Content: logo + title + dots
            VStack(spacing: 0) {
                // Logo: 140x140 rounded rect with gradient from primary to black, border overlay
                ZStack {
                    // Logo gradient background
                    RoundedRectangle(cornerRadius: 35)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: AppColors.primary.opacity(0.2), radius: 50, x: 0, y: 0)

                    // Theta icon centered in logo
                    ThetaIconView(size: 70, fillColor: .black)

                    // Border overlay
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(AppColors.primary.opacity(0.30), lineWidth: 1)
                        .frame(width: 140, height: 140)
                }
                .padding(.bottom, 32)

                // Title text
                Text("ThetaFeed")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppColors.text)
                    .lineSpacing(12)

                // 3 loading dots with staggered opacity animation
                HStack(spacing: 8) {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 8, height: 8)
                        .opacity(dot1Opacity)

                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 8, height: 8)
                        .opacity(dot2Opacity)

                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 8, height: 8)
                        .opacity(dot3Opacity)
                }
                .padding(.top, 48)
            }
            .scaleEffect(contentScale)
        }
        .opacity(fadeOpacity * dismissOpacity)
        .onAppear {
            // Fade in + scale animation on appear
            withAnimation(.easeOut(duration: 0.6)) {
                fadeOpacity = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
                contentScale = 1.0
            }

            // Start staggered dot animations
            startDotAnimations()

            // Auto-dismiss after 2.5s calling onFinish
            dismissTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
                withAnimation(.easeOut(duration: 0.4)) {
                    dismissOpacity = 0
                }
                // Call onFinish after fade-out completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onFinish()
                }
            }
        }
        .onDisappear {
            // Clean up timer
            dismissTimer?.invalidate()
        }
    }

    // MARK: - Dot Animation
    // Animates loading dots with staggered delays (0ms, 150ms, 300ms)
    private func startDotAnimations() {
        // Dot 1 - no delay
        animateDot(opacity: $dot1Opacity, delay: 0)
        // Dot 2 - 150ms delay
        animateDot(opacity: $dot2Opacity, delay: 0.15)
        // Dot 3 - 300ms delay
        animateDot(opacity: $dot3Opacity, delay: 0.30)
    }

    private func animateDot(opacity: Binding<Double>, delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            // Loop: fade to 1.0 then back to 0.3, repeating
            withAnimation(
                .easeInOut(duration: 0.4)
                .repeatForever(autoreverses: true)
            ) {
                opacity.wrappedValue = 1.0
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(onFinish: {})
            .preferredColorScheme(.dark)
    }
}
#endif
