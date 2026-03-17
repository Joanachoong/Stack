import SwiftUI

/// Input screens for collecting user name and age.
///
/// This view manages two sub-screens:
/// 1. Name input screen with a text field
/// 2. Age selection screen with a custom wheel picker
///
/// Converted from components/InputScreens.tsx
struct InputScreensView: View {
    let onComplete: (UserData) -> Void
    let onBack: () -> Void
    var currentStep: Int
    var totalSteps: Int

    @State private var screenIndex: Int = 0
    @State private var firstName: String = ""
    @State private var selectedAge: Int = 25

    private let itemHeight: CGFloat = 48
    private let pickerHeight: CGFloat = 335
    private let ages: [Int] = Array(18...100)

    var actualStep: Int {
        currentStep + screenIndex
    }

    var isButtonDisabled: Bool {
        screenIndex == 0 && firstName.trimmingCharacters(in: .whitespaces).isEmpty
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
                // Header with progress bar and navigation
                headerView

                // Content area
                if screenIndex == 0 {
                    nameScreen
                } else {
                    ageScreen
                }

                Spacer()

                // Footer with NEXT button
                footerView
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 24) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 9999)
                        .fill(AppColors.progressTrack)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 9999)
                        .fill(AppColors.primary)
                        .frame(
                            width: geo.size.width * CGFloat(actualStep) / CGFloat(totalSteps),
                            height: 4
                        )
                        .shadow(color: AppColors.primary, radius: 10)
                        .animation(.easeOut(duration: 0.2), value: actualStep)
                }
            }
            .frame(height: 4)

            // Back button and step counter
            HStack {
                Button(action: handleBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppColors.text)
                        .frame(width: 24, height: 24)
                }

                Spacer()

                Text("\(actualStep) of \(totalSteps)")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(AppColors.textMuted)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(AppColors.border, lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Name Screen

    private var nameScreen: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("Know more about you")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("What is your name?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // Text input field
            TextField("Type your name", text: $firstName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .onSubmit(handleNext)
                .padding(.horizontal, 36)
                .padding(.top, 40)
        }
    }

    // MARK: - Age Screen

    private var ageScreen: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("Age")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("How old are you?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // Wheel picker
            AgeWheelPicker(
                ages: ages,
                selectedAge: $selectedAge,
                itemHeight: itemHeight,
                pickerHeight: pickerHeight
            )
            .padding(.top, 40)
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        PrimaryButton(title: "CONTINUE", action: handleNext)
        .disabled(isButtonDisabled)
        .opacity(isButtonDisabled ? 0.5 : 1.0)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    // MARK: - Actions

    private func handleNext() {
        if screenIndex == 0 {
            let trimmed = firstName.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                withAnimation(.easeInOut(duration: 0.3)) {
                    screenIndex = 1
                }
            }
        } else {
            let data = UserData(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                age: selectedAge
            )
            onComplete(data)
        }
    }

    private func handleBack() {
        if screenIndex == 0 {
            onBack()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                screenIndex = 0
            }
        }
    }
}

// MARK: - Age Wheel Picker

/// Custom wheel picker for age selection with haptic feedback.
///
/// Uses a ScrollViewReader and snapping behavior to simulate
/// a native-style wheel picker with fade gradients at top and bottom.
struct AgeWheelPicker: View {
    let ages: [Int]
    @Binding var selectedAge: Int
    let itemHeight: CGFloat
    let pickerHeight: CGFloat

    var body: some View {
        Picker("Age", selection: $selectedAge) {
            ForEach(ages, id: \.self) { age in
                Text("\(age)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }
        }
        .pickerStyle(.wheel)
        .frame(height: pickerHeight)
        .onChange(of: selectedAge) { _ in
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}

#Preview {
    InputScreensView(
        onComplete: { _ in },
        onBack: {},
        currentStep: 3,
        totalSteps: 10
    )
}
