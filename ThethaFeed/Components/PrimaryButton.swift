//
//  PrimaryButton.swift
//  ThethaFeed
//
//  Created by Joana Choong on 15/02/2026.
//

//
//  PrimaryButton 2.swift
//  ThethaFeed
//
//  Created by Joana Choong on 15/02/2026.
//

import SwiftUI

/// Reusable primary action button used across all onboarding screens.
///
/// Displays a full-width capsule-shaped button with the app's primary color,
/// a subtle shadow, and bold text.
///
/// - Parameters:
///   - title: The text displayed on the button (e.g. "NEXT", "CLICK HERE TO CONTINUE").
///   - action: Callback fired when the button is tapped.
///
/// ## Usage
/// ```swift
/// PrimaryButton(title: "NEXT", action: { handleNext() })
///
/// PrimaryButton(title: "Continue") {
///     navigateForward()
/// }
/// ```
struct PrimaryButton: View {
    /// The text displayed on the button
    let title: String

    /// Callback fired when the button is tapped
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 57)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 13))
                .shadow(color: AppColors.primary.opacity(0.15), radius: 15, x: 0, y: 0)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "NEXT", action: {})
        PrimaryButton(title: "CLICK HERE TO CONTINUE", action: {})
    }
    .padding(.horizontal, 24)
    .background(Color.black)
}
