// Edited disclaimer screens - brightened + bullet points + back on screen 1
// Updated by Aziza Usman on 06 Mar '26

import SwiftUI

// MARK: - DisclaimerItem Model
struct DisclaimerItem: Identifiable {
    let id = UUID()
    let iconType: BulletIconType
    let text: String
    let boldSuffix: String?

    init(iconType: BulletIconType, text: String, boldSuffix: String? = nil) {
        self.iconType = iconType
        self.text = text
        self.boldSuffix = boldSuffix
    }
}

// MARK: - BulletIconType
enum BulletIconType {
    case skull
    case heart
    case scale
    case cross       // for medical
    case book        // for education
    case shield      // for harm reduction
}

// MARK: - DisclaimerScreenType
enum DisclaimerScreenType {
    case warning
    case info
    case checkbox
}

// MARK: - DisclaimerScreenData
struct DisclaimerScreenData: Identifiable {
    let id: String
    let title: String
    let type: DisclaimerScreenType
    let accentColor: Color?
    let category: String?
    let overline: String?
    let headline: String?
    let headlineAccent: String?
    let items: [DisclaimerItem]?
    let description: String?
    let subDescription: String?
    let checkboxLabel: String?
    let buttonText: String
    let heroSymbol: String
    let heroSymbol2: String?
    let heroSymbol3: String?
}

// MARK: - DISCLAIMER_SCREENS
let DISCLAIMER_SCREENS: [DisclaimerScreenData] = [
    // Screen 1: High-Risk Warning
    DisclaimerScreenData(
        id: "high-risk-warning",
        title: "High-Risk Warning",
        type: .warning,
        accentColor: Color(hex: "#FF3B3B"),
        category: nil,
        overline: "BEFORE YOU CONTINUE",
        headline: nil,
        headlineAccent: nil,
        items: [
            DisclaimerItem(iconType: .skull,  text: "Peptide and compound misuse can cause ", boldSuffix: "permanent, irreversible physiological damage."),
            DisclaimerItem(iconType: .heart,  text: "Improper dosing may lead to severe ",     boldSuffix: "hormonal imbalances and organ stress."),
            DisclaimerItem(iconType: .scale,  text: "You are ",                                boldSuffix: "solely responsible for verifying legality of any substance in your jurisdiction."),
        ],
        description: nil,
        subDescription: nil,
        checkboxLabel: nil,
        buttonText: "I Understand",
        heroSymbol: "exclamationmark.triangle.fill",
        heroSymbol2: "cross.circle.fill",
        heroSymbol3: "bolt.fill"
    ),
    // Screen 2: Not Medical Advice
    DisclaimerScreenData(
        id: "not-medical-advice",
        title: "Not Medical Advice",
        type: .info,
        accentColor: Color(hex: "#60A5FA"),   // brighter blue
        category: nil,
        overline: "DISCLAIMER",
        headline: "We do NOT provide dosing or medical guidance.",
        headlineAccent: "NOT",
        items: [
            DisclaimerItem(iconType: .cross, text: "ThetaFeed is ", boldSuffix: "not a substitute for professional medical advice, diagnosis, or treatment."),
            DisclaimerItem(iconType: .cross, text: "Always consult your physician ", boldSuffix: "before starting any protocol or compound."),
            DisclaimerItem(iconType: .cross, text: "Content is ", boldSuffix: "informational only — not a prescription or clinical recommendation."),
        ],
        description: nil,
        subDescription: nil,
        checkboxLabel: nil,
        buttonText: "Continue",
        heroSymbol: "stethoscope",
        heroSymbol2: "cross.fill",
        heroSymbol3: "heart.text.square.fill"
    ),
    // Screen 3: Educational Disclaimer
    DisclaimerScreenData(
        id: "educational-disclaimer",
        title: "Educational Disclaimer",
        type: .info,
        accentColor: Color(hex: "#A78BFA"),   // brighter violet
        category: nil,
        overline: "EDUCATIONAL USE ONLY",
        headline: "ThetaFeed is for education only.",
        headlineAccent: "education",
        items: [
            DisclaimerItem(iconType: .book, text: "All compound information is ", boldSuffix: "strictly for research and educational purposes."),
            DisclaimerItem(iconType: .book, text: "We do not endorse, recommend, or ", boldSuffix: "prescribe any specific substances."),
            DisclaimerItem(iconType: .book, text: "Use this platform to ", boldSuffix: "make informed decisions with your healthcare provider."),
        ],
        description: nil,
        subDescription: nil,
        checkboxLabel: nil,
        buttonText: "Continue",
        heroSymbol: "books.vertical.fill",
        heroSymbol2: "graduationcap.fill",
        heroSymbol3: "doc.text.fill"
    ),
    // Screen 4: Harm Reduction
    DisclaimerScreenData(
        id: "harm-reduction",
        title: "Harm Reduction",
        type: .info,
        accentColor: Color(hex: "#34D399"),   // brighter emerald
        category: nil,
        overline: "OUR MISSION",
        headline: "Our goal is harm reduction.",
        headlineAccent: "harm reduction.",
        items: [
            DisclaimerItem(iconType: .shield, text: "We exist to ", boldSuffix: "minimize risks associated with performance optimization."),
            DisclaimerItem(iconType: .shield, text: "Informed users ", boldSuffix: "make safer, more responsible decisions."),
            DisclaimerItem(iconType: .shield, text: "We encourage evidence-based approaches and ", boldSuffix: "proper medical consultation at all times."),
        ],
        description: nil,
        subDescription: nil,
        checkboxLabel: nil,
        buttonText: "Continue",
        heroSymbol: "shield.lefthalf.filled",
        heroSymbol2: "checkmark.seal.fill",
        heroSymbol3: "leaf.fill"
    ),
    // Screen 5: User Responsibility (checkbox)
    DisclaimerScreenData(
        id: "user-responsibility",
        title: "Your Responsibility",
        type: .checkbox,
        accentColor: AppColors.primary,
        category: "FINAL STEP",
        overline: nil,
        headline: "You are responsible\nfor your decisions.",
        headlineAccent: nil,
        items: nil,
        description: nil,
        subDescription: nil,
        checkboxLabel: "I acknowledge I am solely responsible for my choices and their outcomes.",
        buttonText: "Next",
        heroSymbol: "person.fill.checkmark",
        heroSymbol2: "hand.raised.fill",
        heroSymbol3: "lock.shield.fill"
    ),
]

// MARK: - HeroIllustrationView
struct HeroIllustrationView: View {
    let screen: DisclaimerScreenData
    @State private var float1: Bool = false
    @State private var float2: Bool = false
    @State private var float3: Bool = false
    @State private var pulse:  Bool = false

    private var accent: Color { screen.accentColor ?? AppColors.primary }

    var body: some View {
        ZStack {
            // Outer pulse ring
            Circle()
                .stroke(accent.opacity(pulse ? 0.06 : 0.18), lineWidth: 1.5)
                .frame(width: pulse ? 370 : 310, height: pulse ? 370 : 310)
                .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: pulse)

            // Inner ring
            Circle()
                .stroke(accent.opacity(0.14), lineWidth: 1)
                .frame(width: 260, height: 260)

            // Radial glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.35), Color.clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 175
                    )
                )
                .frame(width: 350, height: 350)
                .blur(radius: 24)

            // Secondary offset blob
            Circle()
                .fill(accent.opacity(0.15))
                .frame(width: 210, height: 210)
                .blur(radius: 40)
                .offset(x: 45, y: 25)

            // Floating symbol 3 — back left
            if let sym3 = screen.heroSymbol3 {
                Image(systemName: sym3)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(accent.opacity(0.45))
                    .offset(x: -105, y: float3 ? 22 : 36)
                    .rotationEffect(.degrees(-15))
                    .animation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true).delay(0.8), value: float3)
            }

            // Floating symbol 2 — upper right
            if let sym2 = screen.heroSymbol2 {
                Image(systemName: sym2)
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundColor(accent.opacity(0.60))
                    .offset(x: 90, y: float2 ? -65 : -52)
                    .rotationEffect(.degrees(12))
                    .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true).delay(0.3), value: float2)
            }

            // Sparkle dots — brighter
            ForEach(0..<4, id: \.self) { i in
                let xO: [CGFloat] = [-60,  80, -40,  65]
                let yO: [CGFloat] = [-70,  50,  60, -30]
                Circle()
                    .fill(accent.opacity(0.65))
                    .frame(width: 5, height: 5)
                    .offset(x: xO[i], y: yO[i])
                    .scaleEffect(float1 ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 2.0 + Double(i) * 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.3),
                        value: float1
                    )
            }

            // Main hero symbol
            Image(systemName: screen.heroSymbol)
                .font(.system(size: 110, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [accent, accent.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: accent.opacity(0.7), radius: 36, x: 0, y: 8)  // stronger glow
                .offset(y: float1 ? -7 : 7)
                .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: float1)

            // Diamond sparks
            Image(systemName: "diamond.fill")
                .font(.system(size: 10))
                .foregroundColor(accent.opacity(0.65))
                .offset(x: -100, y: -30)
                .scaleEffect(float2 ? 1.3 : 0.6)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(1.0), value: float2)

            Image(systemName: "diamond.fill")
                .font(.system(size: 6))
                .foregroundColor(accent.opacity(0.45))
                .offset(x: 95, y: 65)
                .scaleEffect(float3 ? 1.4 : 0.5)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5), value: float3)
        }
        .frame(maxWidth: .infinity)
        .onAppear { float1 = true; float2 = true; float3 = true; pulse = true }
    }
}

// MARK: - BulletIconView
struct BulletIconView: View {
    let type: BulletIconType
    let color: Color

    var systemName: String {
        switch type {
        case .skull:  return "exclamationmark.triangle"
        case .heart:  return "heart"
        case .scale:  return "scalemass"
        case .cross:  return "cross.circle"
        case .book:   return "book"
        case .shield: return "shield.lefthalf.filled"
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.16))
                .frame(width: 30, height: 30)
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(color)
        }
    }
}

// MARK: - TnC Scroll Preference Key
struct TnCScrollKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - DisclaimerScreensView
struct DisclaimerScreensView: View {
    let onComplete: () -> Void
    let totalOnboardingSteps: Int

    @State private var currentIndex: Int = 0
    @State private var acknowledged: Bool = false
    @State private var contentOpacity: Double = 1.0
    @State private var contentOffsetY: CGFloat = 0
    @State private var hasScrolledTnC: Bool = false

    private var currentScreen: DisclaimerScreenData { DISCLAIMER_SCREENS[currentIndex] }
    private var currentStep: Int { currentIndex + 2 }
    private var progressFraction: CGFloat { CGFloat(currentStep) / CGFloat(totalOnboardingSteps) }
    private var isButtonDisabled: Bool { currentScreen.type == .checkbox && (!acknowledged || !hasScrolledTnC) }
    private var accent: Color { currentScreen.accentColor ?? AppColors.primary }

    var body: some View {
        GeometryReader { geo in
        ZStack {
            // Full-bleed background — brighter accent color fills entire screen
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
            .animation(.easeInOut(duration: 0.65), value: currentIndex)

            // Subtle noise grain
            Rectangle()
                .fill(.white.opacity(0.018))
                .ignoresSafeArea()
                .blendMode(.overlay)

            VStack(spacing: 0) {
                headerSection

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HeroIllustrationView(screen: currentScreen)
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
            // Progress bar
            GeometryReader { track in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 9999)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 9999)
                        .fill(AppColors.primary)
                        .frame(width: track.size.width * progressFraction, height: 4)
                        .shadow(color: AppColors.primary.opacity(0.9), radius: 8)
                        .animation(.easeInOut(duration: 0.4), value: progressFraction)
                }
            }
            .frame(height: 4)

            HStack {
                // Back button — icon only, visible on all screens, hidden (opacity 0) on first
                Button(action: handleBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.text.opacity(0.80))
                        .frame(width: 36, height: 36)
                }
                .opacity(currentIndex == 0 ? 0 : 1)
                .disabled(currentIndex == 0)
                .animation(.easeInOut(duration: 0.2), value: currentIndex)

                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 6)
    }

    // MARK: - Bottom Panel
    @ViewBuilder
    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Overline
            if let overline = currentScreen.overline {
                Text(overline)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(accent)
                    .kerning(1.4)
                    .padding(.bottom, 6)
            }

            // Category label (checkbox screen)
            if let category = currentScreen.category {
                Text(category)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(accent)
                    .kerning(1.4)
                    .padding(.bottom, 6)
            }

            // Title
            if !currentScreen.title.isEmpty {
                Text(currentScreen.title)
                    .font(.system(size: 27, weight: .bold))
                    .foregroundColor(.white)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 10)
            } else if let headline = currentScreen.headline {
                Text(headline)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 10)
            }

            // Screen-specific body
            switch currentScreen.type {
            case .warning:  warningContent
            case .info:     infoContent
            case .checkbox: checkboxContent
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Warning Content (unchanged structure, kept as reference style)
    private var warningContent: some View {
        VStack(spacing: 0) {
            if let items = currentScreen.items {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        HStack(alignment: .top, spacing: 14) {
                            BulletIconView(type: item.iconType, color: accent)

                            Group {
                                if let bold = item.boldSuffix {
                                    Text(item.text).foregroundColor(Color.white.opacity(0.65))
                                    + Text(bold).foregroundColor(.white).fontWeight(.semibold)
                                } else {
                                    Text(item.text).foregroundColor(Color.white.opacity(0.65))
                                }
                            }
                            .font(.system(size: 14))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)

                            Spacer()
                        }
                        .padding(.vertical, 14)

                        if index < items.count - 1 {
                            Rectangle()
                                .fill(accent.opacity(0.15))
                                .frame(height: 1)
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(accent.opacity(0.09))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(accent.opacity(0.30), lineWidth: 1)
                        )
                        .shadow(color: accent.opacity(0.15), radius: 24, x: 0, y: 0)
                )
            }
        }
    }

    // MARK: - Info Content (now bullet-point based, matching warning style)
    private var infoContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Headline with accent word highlight
            if let headline = currentScreen.headline, let accentWord = currentScreen.headlineAccent {
                buildAccentHeadline(full: headline, accent: accentWord, color: accent)
                    .font(.system(size: 17, weight: .bold))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
            }

            Rectangle()
                .fill(Color.white.opacity(0.09))
                .frame(height: 1)
                .padding(.bottom, 10)

            // Bullet points — same style as warning screen
            if let items = currentScreen.items {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        HStack(alignment: .top, spacing: 14) {
                            BulletIconView(type: item.iconType, color: accent)

                            Group {
                                if let bold = item.boldSuffix {
                                    Text(item.text).foregroundColor(Color.white.opacity(0.65))
                                    + Text(bold).foregroundColor(.white).fontWeight(.semibold)
                                } else {
                                    Text(item.text).foregroundColor(Color.white.opacity(0.65))
                                }
                            }
                            .font(.system(size: 14))
                            .lineSpacing(3)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 7)

                        if index < items.count - 1 {
                            Rectangle()
                                .fill(accent.opacity(0.12))
                                .frame(height: 1)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(accent.opacity(0.09))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(accent.opacity(0.28), lineWidth: 1)
                )
                .shadow(color: accent.opacity(0.18), radius: 28, x: 0, y: 0)
        )
    }

    // MARK: - Checkbox Content
    @ViewBuilder
    private var checkboxContent: some View {
        // T&C scrollable box
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    tncText
                    // Invisible anchor at bottom to detect scroll completion
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                // Will be triggered when this comes into view via scroll detection below
                            }
                            .preference(key: TnCScrollKey.self, value: proxy.frame(in: .named("tncScroll")).maxY)
                    }
                    .frame(height: 1)
                }
                .padding(16)
            }
            .coordinateSpace(name: "tncScroll")
            .onPreferenceChange(TnCScrollKey.self) { maxY in
                // When the bottom anchor is visible (maxY <= scroll view height ~180), unlock
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

            // Fade-out gradient at bottom when not yet scrolled
            if !hasScrolledTnC {
                LinearGradient(
                    colors: [Color.clear, accent.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)
                .allowsHitTesting(false)

                // "Scroll to continue" hint
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
        .padding(.top, 4)

        // Checkbox — locked until scrolled
        Button {
            guard hasScrolledTnC else { return }
            withAnimation(.easeInOut(duration: 0.2)) { acknowledged.toggle() }
        } label: {
            HStack(spacing: 14) {
                Text("1.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(acknowledged ? accent : Color.white.opacity(0.3))

                Text(currentScreen.checkboxLabel ?? "")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(hasScrolledTnC ? Color.white.opacity(0.85) : Color.white.opacity(0.35))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                Circle()
                    .stroke(
                        acknowledged ? accent : (hasScrolledTnC ? Color.white.opacity(0.22) : Color.white.opacity(0.10)),
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
            .opacity(hasScrolledTnC ? 1.0 : 0.45)
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }

    // MARK: - T&C Text
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

    // MARK: - Accent Headline Builder
    private func buildAccentHeadline(full: String, accent: String, color: Color) -> Text {
        guard let range = full.range(of: accent) else {
            return Text(full).foregroundColor(.white)
        }
        let before = String(full[full.startIndex..<range.lowerBound])
        let after  = String(full[range.upperBound..<full.endIndex])
        return Text(before).foregroundColor(.white)
             + Text(accent).foregroundColor(color)
             + Text(after).foregroundColor(.white)
    }

    // MARK: - Nav Dots
    private var navDots: some View {
        HStack(spacing: 5) {
            ForEach(0..<DISCLAIMER_SCREENS.count, id: \.self) { i in
                Capsule()
                    .fill(i == currentIndex ? accent : Color.white.opacity(0.2))
                    .frame(width: i == currentIndex ? 20 : 5, height: 5)
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: - Footer
    private var footerSection: some View {
        Button(action: handleNext) {
            Text(currentScreen.buttonText.uppercased())
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isButtonDisabled ? Color.white.opacity(0.25) : Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background {
                    ZStack {
                        // Accent tint base
                        Capsule()
                            .fill(accent.opacity(0.35))

                        // Glass material on top
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .opacity(0.6)

                        // Top highlight shimmer
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.30),
                                        Color.white.opacity(0.03)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        // Specular top edge line
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
                                colors: [
                                    Color.white.opacity(0.50),
                                    accent.opacity(0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
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

    // MARK: - Navigation
    private func handleNext() {
        guard !isButtonDisabled else { return }
        if currentIndex < DISCLAIMER_SCREENS.count - 1 {
            animateTransition(forward: true) { currentIndex += 1; acknowledged = false }
        } else {
            onComplete()
        }
    }

    private func handleBack() {
        guard currentIndex > 0 else { return }
        animateTransition(forward: false) { currentIndex -= 1; acknowledged = false }
    }

    private func animateTransition(forward: Bool, update: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.15)) {
            contentOpacity = 0
            contentOffsetY = forward ? -14 : 14
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            update()
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
struct DisclaimerScreensView_Previews: PreviewProvider {
    static var previews: some View {
        DisclaimerScreensView(onComplete: {}, totalOnboardingSteps: 10)
            .preferredColorScheme(.dark)
    }
}
#endif
