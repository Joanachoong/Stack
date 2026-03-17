import SwiftUI

/// Paywall/membership upsell screen
struct PaywallScreenView: View {
    let onClose: () -> Void
    let onStartMembership: () -> Void
    let currentStep: Int
    let totalSteps: Int

    @State private var ctaPulse: CGFloat = 1.0

    private let features = [
        "Personalized Peptide Strategy",
        "Dosing & Cycle Guidelines",
        "Source Verification Guide",
        "Community & Expert Access",
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
                // Progress bar
                ProgressBarView(current: currentStep, total: totalSteps)
                    .padding(.top, 60)
                    .padding(.horizontal, 24)

                // Close button
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 24) {
                        // Launch offer badge
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                            Text("LAUNCH OFFER ENDS SOON")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(20)
                        .padding(.top, 20)

                        // Title
                        Text("Your Protocol\nis Ready")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)

                        // Subtitle
                        Text("Start your optimized\ntransformation today.")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textMuted)
                            .multilineTextAlignment(.center)

                        // Features list
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(features, id: \.self) { feature in
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColors.primary)
                                    Text(feature)
                                        .font(.system(size: 15))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.horizontal, 32)

                        // Pricing card
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Text("$19.99")
                                    .font(.system(size: 16))
                                    .strikethrough()
                                    .foregroundColor(AppColors.textMuted)

                                Text("$9.99/month")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                            }

                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.primary)
                                Text("50% OFF FIRST MONTH")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(16)
                        .padding(.horizontal, 24)

                        // CTA Button
                        Button(action: onStartMembership) {
                            Text("Start Membership")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppColors.primary)
                                .cornerRadius(28)
                                .shadow(color: AppColors.primary.opacity(0.3), radius: 12)
                        }
                        .scaleEffect(ctaPulse)
                        .padding(.horizontal, 24)

                        // Terms
                        Text("Recurring billing. Cancel anytime.")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textMuted)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            // Subtle pulse animation on CTA
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                ctaPulse = 1.02
            }
        }
    }
}

#Preview {
    PaywallScreenView(
        onClose: {},
        onStartMembership: {},
        currentStep: 8,
        totalSteps: 10
    )
}
