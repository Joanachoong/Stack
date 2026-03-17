import SwiftUI

// MARK: - Consent Screen Definition

/// Defines a single consent screen with its content, hero symbols, and action text.
private struct ConsentScreen: Identifiable {
    let id: String
    let category: String
    let headline: String
    let checkboxLabel: String
    let buttonText: String
    let heroSymbol: String
    let heroSymbol2: String?
    let heroSymbol3: String?
}

// MARK: - Consent Screen Data

/// Array of consent screens displayed sequentially.
private let CONSENT_SCREENS: [ConsentScreen] = [
    ConsentScreen(
        id: "terms-of-use",
        category: "TERMS OF USE",
        headline: "Review and accept terms of use.",
        checkboxLabel: "I agree",
        buttonText: "NEXT",
        heroSymbol: "doc.text.fill",
        heroSymbol2: "checkmark.seal.fill",
        heroSymbol3: "hand.raised.fill"
    ),
    ConsentScreen(
        id: "final-consent",
        category: "FINAL CONSENT",
        headline: "By continuing, I agree and understand this is not medical advice.",
        checkboxLabel: "I accept",
        buttonText: "NEXT",
        heroSymbol: "person.fill.checkmark",
        heroSymbol2: "lock.shield.fill",
        heroSymbol3: "checkmark.circle.fill"
    ),
]

// MARK: - ConsentScreensView

/// Two-screen consent flow styled to match Disclaimer Screen 5 (checkbox/User Responsibility).
struct ConsentScreensView: View {
    let onComplete: () -> Void
    let onBack: () -> Void
    let currentStep: Int
    let totalSteps: Int

    // MARK: - State
    @State private var screenIndex: Int = 0
    @State private var acknowledged: Bool = false
    @State private var contentOpacity: Double = 1.0
    @State private var contentOffsetY: CGFloat = 0
    @State private var hasScrolledTnC: Bool = false

    // MARK: - Computed Properties

    private var currentScreen: ConsentScreen { CONSENT_SCREENS[screenIndex] }
    private var accent: Color { AppColors.primary }

    private var isButtonDisabled: Bool {
        if screenIndex == 0 {
            return !acknowledged || !hasScrolledTnC
        }
        return !acknowledged
    }

    /// Build a DisclaimerScreenData adapter so HeroIllustrationView can be reused directly.
    private var heroScreenData: DisclaimerScreenData {
        DisclaimerScreenData(
            id: currentScreen.id,
            title: "",
            type: .checkbox,
            accentColor: AppColors.primary,
            category: nil,
            overline: nil,
            headline: nil,
            headlineAccent: nil,
            items: nil,
            description: nil,
            subDescription: nil,
            checkboxLabel: nil,
            buttonText: currentScreen.buttonText,
            heroSymbol: currentScreen.heroSymbol,
            heroSymbol2: currentScreen.heroSymbol2,
            heroSymbol3: currentScreen.heroSymbol3
        )
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Full-bleed gradient background — mirrors Disclaimer
                LinearGradient(
                    colors: [
                        accent.opacity(0.70),
                        accent.opacity(0.45),
                        accent.opacity(0.22)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.65), value: screenIndex)

                // Noise grain overlay
                Rectangle()
                    .fill(.white.opacity(0.018))
                    .ignoresSafeArea()
                    .blendMode(.overlay)

                VStack(spacing: 0) {
                    headerSection

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Animated hero illustration — reuses HeroIllustrationView from DisclaimerScreensView
                            HeroIllustrationView(screen: heroScreenData)
                                .frame(height: 220)

                            bottomPanel
                                .padding(.horizontal, 24)
                                .padding(.top, 10)
                                .padding(.bottom, 24)
                        }
                        .frame(minHeight: geo.size.height - 200)
                    }
                    .frame(maxHeight: .infinity)
                    .opacity(contentOpacity)
                    .offset(y: contentOffsetY)

                    navDots
                    footerSection
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 20) {
            // Progress bar — Disclaimer style
            GeometryReader { track in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 9999)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 9999)
                        .fill(AppColors.primary)
                        .frame(
                            width: track.size.width * min(1.0, CGFloat(currentStep + screenIndex) / CGFloat(max(1, totalSteps))),
                            height: 4
                        )
                        .shadow(color: AppColors.primary.opacity(0.9), radius: 8)
                        .animation(.easeInOut(duration: 0.4), value: screenIndex)
                }
            }
            .frame(height: 4)

            HStack {
                // Back button — hidden (opacity 0) on first screen, matches Disclaimer
                Button(action: handleBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.text.opacity(0.80))
                        .frame(width: 36, height: 36)
                }
                .opacity(screenIndex == 0 ? 0 : 1)
                .disabled(screenIndex == 0)
                .animation(.easeInOut(duration: 0.2), value: screenIndex)

                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 6)
    }

    // MARK: - Bottom Panel

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Category label — kerned, accent color (matches Disclaimer overline/category style)
            Text(currentScreen.category)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(accent)
                .kerning(1.4)
                .padding(.bottom, 6)

            // Headline in white
            Text(currentScreen.headline)
                .font(.system(size: 27, weight: .bold))
                .foregroundColor(.white)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 12)

            // Screen 1 only: T&C scrollable box with scroll gate
            if screenIndex == 0 {
                tncScrollBox
            }

            // Checkbox card — Disclaimer style
            checkboxCard
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - T&C Scroll Box (Screen 1 only)

    private var tncScrollBox: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    tncText
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: TnCScrollKey.self, value: proxy.frame(in: .named("tncScroll")).maxY)
                    }
                    .frame(height: 1)
                }
                .padding(16)
            }
            .coordinateSpace(name: "tncScroll")
            .onPreferenceChange(TnCScrollKey.self) { maxY in
                if maxY <= 185 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasScrolledTnC = true
                    }
                }
            }
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )

            // Fade-out gradient + scroll hint when not yet scrolled
            if !hasScrolledTnC {
                LinearGradient(
                    colors: [Color.clear, accent.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)
                .allowsHitTesting(false)

                VStack(spacing: 4) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    Text("Scroll to continue")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 10)
                .allowsHitTesting(false)
            }
        }
        .padding(.bottom, 12)
    }

    // MARK: - T&C Text Content

    private var tncText: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Terms & Conditions")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)

            Group {
                Text("1. Acceptance of Terms")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                Text("By using ThetaFeed, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use this application.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
                    .lineSpacing(3)

                Text("2. No Medical Advice")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                Text("ThetaFeed does not provide medical advice, diagnosis, or treatment. All content is for informational and educational purposes only. Always consult a qualified healthcare professional before making any health-related decisions.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
                    .lineSpacing(3)

                Text("3. User Responsibility")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                Text("You are solely responsible for your decisions, actions, and their outcomes. ThetaFeed and its team accept no liability for any harm, injury, or legal consequences arising from your use of information provided through this platform.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
                    .lineSpacing(3)

                Text("4. Legality")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                Text("You are responsible for verifying the legality of any substance or protocol discussed in ThetaFeed within your jurisdiction. Laws vary by region and it is your duty to comply with all applicable laws and regulations.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
                    .lineSpacing(3)

                Text("5. Limitation of Liability")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                Text("To the fullest extent permitted by law, ThetaFeed shall not be liable for any direct, indirect, incidental, special, or consequential damages resulting from your use of or inability to use this application.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
                    .lineSpacing(3)
            }
        }
    }

    // MARK: - Checkbox Card (Disclaimer style)

    private var checkboxCard: some View {
        let isLocked = screenIndex == 0 && !hasScrolledTnC

        return Button {
            guard !isLocked else { return }
            withAnimation(.easeInOut(duration: 0.2)) { acknowledged.toggle() }
        } label: {
            HStack(spacing: 14) {
                Text("1.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(acknowledged ? accent : Color.white.opacity(0.3))

                Text(currentScreen.checkboxLabel)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isLocked ? Color.white.opacity(0.35) : Color.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                Circle()
                    .stroke(
                        acknowledged ? accent : (isLocked ? Color.white.opacity(0.10) : Color.white.opacity(0.22)),
                        lineWidth: acknowledged ? 5 : 1.5
                    )
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(acknowledged ? accent.opacity(0.11) : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(acknowledged ? accent.opacity(0.32) : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .shadow(color: acknowledged ? accent.opacity(0.18) : .clear, radius: 18, x: 0, y: 0)
            .opacity(isLocked ? 0.45 : 1.0)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    // MARK: - Nav Dots

    private var navDots: some View {
        HStack(spacing: 5) {
            ForEach(0..<CONSENT_SCREENS.count, id: \.self) { i in
                Capsule()
                    .fill(i == screenIndex ? accent : Color.white.opacity(0.2))
                    .frame(width: i == screenIndex ? 20 : 5, height: 5)
                    .animation(.easeInOut(duration: 0.25), value: screenIndex)
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: - Footer (Glassmorphic button — mirrors Disclaimer)

    private var footerSection: some View {
        Button(action: handleNext) {
            Text(currentScreen.buttonText.uppercased())
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isButtonDisabled ? Color.white.opacity(0.25) : Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background {
                    ZStack {
                        Capsule().fill(accent.opacity(0.35))
                        Capsule().fill(.ultraThinMaterial).opacity(0.6)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.30), Color.white.opacity(0.03)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                        Capsule()
                            .fill(Color.white.opacity(0.20))
                            .frame(height: 1)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .padding(.horizontal, 20)
                            .padding(.top, 1)
                    }
                }
                .overlay(
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.50), accent.opacity(0.25)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: accent.opacity(0.35), radius: 16, x: 0, y: 6)
                .opacity(isButtonDisabled ? 0.4 : 1.0)
        }
        .disabled(isButtonDisabled)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 36)
    }

    // MARK: - Navigation Handlers

    private func handleNext() {
        guard !isButtonDisabled else { return }

        if screenIndex < CONSENT_SCREENS.count - 1 {
            animateTransition(forward: true) {
                screenIndex += 1
                acknowledged = false
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) { contentOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onComplete() }
        }
    }

    private func handleBack() {
        if screenIndex == 0 {
            onBack()
        } else {
            animateTransition(forward: false) {
                screenIndex -= 1
                acknowledged = false
            }
        }
    }

    // MARK: - Transition Animation

    private func animateTransition(forward: Bool, callback: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.15)) {
            contentOpacity = 0
            contentOffsetY = forward ? -14 : 14
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            callback()
            hasScrolledTnC = false
            contentOffsetY = forward ? 18 : -18
            withAnimation(.easeOut(duration: 0.28)) {
                contentOpacity = 1
                contentOffsetY = 0
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ConsentScreensView_Previews: PreviewProvider {
    static var previews: some View {
        ConsentScreensView(
            onComplete: {},
            onBack: {},
            currentStep: 18,
            totalSteps: 20
        )
        .preferredColorScheme(.dark)
    }
}
#endif
