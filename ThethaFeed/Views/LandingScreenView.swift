import SwiftUI

// MARK: - LandingScreenView
// Converted from components/LandingScreen.tsx (242 lines)
// Displays the landing/welcome screen with background image, logo, title,
// subtitle, and two action buttons (Get Started + Sign In)

// MARK: - ArrowIcon Shape
// SVG: M3 9H15M15 9L10 4M15 9L10 14 (right-pointing arrow)
struct ArrowIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scaleX = rect.width / 18.0
        let scaleY = rect.height / 18.0

        // Horizontal line: M3 9H15
        path.move(to: CGPoint(x: 3 * scaleX, y: 9 * scaleY))
        path.addLine(to: CGPoint(x: 15 * scaleX, y: 9 * scaleY))

        // Upper arrowhead: M15 9L10 4
        path.move(to: CGPoint(x: 15 * scaleX, y: 9 * scaleY))
        path.addLine(to: CGPoint(x: 10 * scaleX, y: 4 * scaleY))

        // Lower arrowhead: M15 9L10 14
        path.move(to: CGPoint(x: 15 * scaleX, y: 9 * scaleY))
        path.addLine(to: CGPoint(x: 10 * scaleX, y: 14 * scaleY))

        return path
    }
}

struct LandingScreenView: View {
    // Callbacks for button actions
    let onGetStarted: () -> Void
    let onSignIn: () -> Void

    // Button press animation (scale spring)
    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppColors.background.ignoresSafeArea()

                // Background image (AsyncImage from URL)
                AsyncImage(
                    url: URL(string: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80")
                ) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(0.4)
                    case .failure:
                        // Fallback: empty background on failure
                        Color.clear
                    case .empty:
                        // Loading state: empty background
                        Color.clear
                    @unknown default:
                        Color.clear
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .ignoresSafeArea()

                // Two overlaid gradients (green glow at top, dark at bottom)
                // Green glow gradient at top
                LinearGradient(
                    colors: [
                        AppColors.primary.opacity(0.25),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: UnitPoint(x: 0.5, y: 0.35)
                )
                .ignoresSafeArea()

                // Smooth fade from photo into background (no seam)
                LinearGradient(
                    colors: [
                        Color.clear,
                        AppColors.background.opacity(0.5),
                        AppColors.background.opacity(0.85),
                        AppColors.background
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0.35),
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Content aligned to bottom
                VStack(spacing: 0) {
                    Spacer()

                    VStack(alignment: .leading, spacing: 0) {
                        // Logo row: small gradient rounded rect + "ThetaFeed" text
                        HStack(spacing: 12) {
                            // Small logo with gradient and border
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColors.primary, AppColors.primaryDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                                    )

                                // Theta icon (small, 25x25)
                                ThetaIconView(size: 25, fillColor: .black)
                            }

                            Text("ThetaFeed")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.text)
                        }
                        .padding(.bottom, 24)

                        // Title "Master your\nPerformance." with green highlight on "Performance."
                        (
                            Text("Master your\n")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(Color.black)
                            +
                            Text("Performance.")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        )
                        .lineSpacing(0)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 16)

                        // Subtitle text
                        Text("Data-driven protocols for optimization,\nlongevity, and peak output.")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(AppColors.textMuted)
                            .lineSpacing(5)
                            .padding(.bottom, 32)

                        // Buttons container
                        VStack(spacing: 16) {
                            // Get Started button: LinearGradient (primary to #8FB535), pill shape, arrow icon
                            Button(action: {
                                onGetStarted()
                            }) {
                                HStack(spacing: 8) {
                                    Text("Get Started")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color.black)

                                    // Arrow icon
                                    ArrowIconShape()
                                        .stroke(Color.black, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                        .frame(width: 18, height: 18)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.primary, Color(hex: "#8FB535")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: AppColors.primary.opacity(0.2), radius: 20, x: 0, y: 0)
                            }
                            // Button press animation (scale spring)
                            .scaleEffect(buttonScale)
                            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    buttonScale = pressing ? 0.98 : 1.0
                                }
                            }, perform: {})

                            // Secondary "I already have an account" button
                            Button(action: {
                                onSignIn()
                            }) {
                                Text("I already have an account")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppColors.text)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(AppColors.surfaceSelected)
                                    .overlay(
                                        Capsule()
                                            .stroke(AppColors.border, lineWidth: 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    // Safe area insets handling
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 48)
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Preview
#if DEBUG
struct LandingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LandingScreenView(
            onGetStarted: {},
            onSignIn: {}
        )
        .preferredColorScheme(.dark)
    }
}
#endif
