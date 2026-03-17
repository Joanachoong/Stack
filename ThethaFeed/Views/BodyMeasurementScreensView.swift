import SwiftUI

// MARK: - Body Measurement Screens View
// Converted from components/BodyMeasurementScreens.tsx (663 lines)
// 2 screens: weight picker + height picker
// Weight: Picker .wheel style, lbs/kg toggle, range 80-380 lbs or 35-170 kg
// Height: imperial (feet 4-8 + inches 0-11) or metric (cm 120-210) with toggle
// Unit conversion on toggle (lbs<>kg, ft/in<>cm)
// Progress bar, back button, step counter
// Screen transitions
// Haptic feedback on selection
// onComplete callback with weight, weightUnit, height, heightUnit

// MARK: - Body Measurement Data
// Uses BodyData, WeightUnit, HeightUnit from QuestionModels.swift

// MARK: - Constants

/// Height of each wheel picker item row
private let ITEM_HEIGHT: CGFloat = 48

/// Total visible height of the picker area
private let PICKER_HEIGHT: CGFloat = 335

/// Weight values in lbs (80-380)
private let WEIGHTS_LBS: [Int] = Array(80...380)

/// Weight values in kg (35-170)
private let WEIGHTS_KG: [Int] = Array(35...170)

/// Feet values (4-8)
private let FEET: [Int] = Array(4...8)

/// Inches values (0-11)
private let INCHES: [Int] = Array(0...11)

/// Centimeter values (120-210)
private let CM_VALUES: [Int] = Array(120...210)

// MARK: - BodyMeasurementScreensView

/// Two-screen body measurement flow: weight picker + height picker.
///
/// Features:
/// - Weight screen: Picker .wheel style with lbs/kg toggle, range 80-380 lbs or 35-170 kg
/// - Height screen: imperial (feet 4-8 + inches 0-11) or metric (cm 120-210) with toggle
/// - Unit conversion on toggle (lbs<>kg, ft/in<>cm)
/// - Progress bar, back button, step counter
/// - Screen transitions with fade + slide animation
/// - Haptic feedback on selection changes
/// - onComplete callback with weight, weightUnit, height, heightUnit
struct BodyMeasurementScreensView: View {
    /// Callback when both screens are completed with measurement data
    let onComplete: (BodyData) -> Void

    /// Callback when back is pressed on the first screen
    let onBack: () -> Void

    /// Current step in the overall onboarding flow
    let currentStep: Int

    /// Total steps in the overall onboarding flow
    let totalSteps: Int

    // MARK: - State

    /// Current sub-screen index (0 = weight, 1 = height)
    @State private var screenIndex: Int = 0

    /// Current weight unit selection
    @State private var weightUnit: WeightUnit = .lbs

    /// Selected weight value
    @State private var selectedWeight: Int = 150

    /// Current height unit selection
    @State private var heightUnit: HeightUnit = .imperial

    /// Selected feet value (imperial)
    @State private var selectedFeet: Int = 5

    /// Selected inches value (imperial)
    @State private var selectedInches: Int = 9

    /// Selected centimeters value (metric)
    @State private var selectedCm: Int = 175

    /// Content opacity for screen transition animation
    @State private var contentOpacity: Double = 1.0

    /// Content vertical offset for screen transition animation
    @State private var contentOffset: CGFloat = 0

    // MARK: - Computed Properties

    /// The actual step including the sub-screen offset
    private var actualStep: Int {
        currentStep + screenIndex
    }

    /// Progress bar fill fraction
    private var progressFraction: CGFloat {
        CGFloat(actualStep) / CGFloat(totalSteps)
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
            AppColors.background.ignoresSafeArea()

                LinearGradient(
                    colors: [AppColors.primary.opacity(0.18), .clear],
                    startPoint: .top,
                    endPoint: .init(x: 0.5, y: 0.35)
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: Header — Progress bar + Back button + Step counter
                    VStack(spacing: 24) {
                        // Progress bar track
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 9999)
                                .fill(AppColors.progressTrack)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 9999)
                                .fill(AppColors.primary)
                                .frame(width: progressFraction * (geometry.size.width - 48), height: 4)
                                .shadow(color: AppColors.primary, radius: 10, x: 0, y: 0)
                                .animation(.easeOut(duration: 0.2), value: actualStep)
                        }

                        // Header row: back button + step counter
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
                    .padding(.top, geometry.safeAreaInsets.top + 16)

                    // MARK: Animated Content — Weight or Height screen
                    Group {
                        if screenIndex == 0 {
                            weightScreen(geometry: geometry)
                        } else {
                            heightScreen(geometry: geometry)
                        }
                    }
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                    // MARK: Footer — NEXT button
                    PrimaryButton(title: "CONTINUE", action: handleNext)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 24)
                }
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Weight Screen

    /// Renders the weight picker screen with unit toggle and wheel picker.
    @ViewBuilder
    private func weightScreen(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Question area
            VStack(spacing: 4) {
                Text("Weight")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("What is your current weight?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // Unit toggle: lbs / kg
            HStack(spacing: 12) {
                unitToggleButton(label: "lbs", isActive: weightUnit == .lbs) {
                    if weightUnit != .lbs { toggleWeightUnit() }
                }
                unitToggleButton(label: "kg", isActive: weightUnit == .kg) {
                    if weightUnit != .kg { toggleWeightUnit() }
                }
            }
            .padding(.top, 24)

            // Weight wheel picker
            Picker("Weight", selection: $selectedWeight) {
                ForEach(weightUnit == .lbs ? WEIGHTS_LBS : WEIGHTS_KG, id: \.self) { value in
                    Text("\(value) \(weightUnit.rawValue)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.primary)
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: PICKER_HEIGHT)
            .padding(.top, 24)
            .onChange(of: selectedWeight) { _ in
                // Haptic feedback on selection change
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
            }

            Spacer()
        }
    }

    // MARK: - Height Screen

    /// Renders the height picker screen with unit toggle and wheel picker(s).
    @ViewBuilder
    private func heightScreen(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Question area
            VStack(spacing: 4) {
                Text("Height")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("What is your height?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // Unit toggle: ft/in / cm
            HStack(spacing: 12) {
                unitToggleButton(label: "ft/in", isActive: heightUnit == .imperial) {
                    if heightUnit != .imperial { toggleHeightUnit() }
                }
                unitToggleButton(label: "cm", isActive: heightUnit == .metric) {
                    if heightUnit != .metric { toggleHeightUnit() }
                }
            }
            .padding(.top, 24)

            // Height picker(s)
            if heightUnit == .imperial {
                // Imperial: feet + inches side by side
                HStack(spacing: 16) {
                    // Feet picker
                    Picker("Feet", selection: $selectedFeet) {
                        ForEach(FEET, id: \.self) { value in
                            Text("\(value)'")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppColors.primary)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: PICKER_HEIGHT)

                    // Inches picker
                    Picker("Inches", selection: $selectedInches) {
                        ForEach(INCHES, id: \.self) { value in
                            Text("\(value)\"")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppColors.primary)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: PICKER_HEIGHT)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .onChange(of: selectedFeet) { _ in
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                }
                .onChange(of: selectedInches) { _ in
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                }
            } else {
                // Metric: single cm picker
                Picker("Height", selection: $selectedCm) {
                    ForEach(CM_VALUES, id: \.self) { value in
                        Text("\(value) cm")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.primary)
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: PICKER_HEIGHT)
                .padding(.top, 24)
                .onChange(of: selectedCm) { _ in
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                }
            }

            Spacer()
        }
    }

    // MARK: - Unit Toggle Button

    /// A reusable toggle button for unit selection.
    @ViewBuilder
    private func unitToggleButton(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isActive ? AppColors.primary : AppColors.textMuted)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(isActive ? AppColors.primary.opacity(0.2) : Color.white.opacity(0.05))
                        .overlay(
                            Capsule()
                                .strokeBorder(isActive ? AppColors.primary : Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
        }
    }

    // MARK: - Navigation Handlers

    /// Handles NEXT button press.
    /// On weight screen: transitions to height screen.
    /// On height screen: calls onComplete with measurement data.
    private func handleNext() {
        if screenIndex == 0 {
            animateTransition(forward: true) {
                screenIndex = 1
            }
        } else {
            let heightValue = heightUnit == .imperial
                ? selectedFeet * 12 + selectedInches
                : selectedCm
            onComplete(BodyData(
                weight: Double(selectedWeight),
                weightUnit: weightUnit,
                height: Double(heightValue),
                heightUnit: heightUnit
            ))
        }
    }

    /// Handles back button press.
    /// On weight screen: calls onBack to exit.
    /// On height screen: transitions back to weight screen.
    private func handleBack() {
        if screenIndex == 0 {
            onBack()
        } else {
            animateTransition(forward: false) {
                screenIndex = 0
            }
        }
    }

    // MARK: - Unit Conversion

    /// Toggles weight unit between lbs and kg with conversion.
    private func toggleWeightUnit() {
        if weightUnit == .lbs {
            let converted = Int(round(Double(selectedWeight) * 0.453592))
            weightUnit = .kg
            selectedWeight = converted
        } else {
            let converted = Int(round(Double(selectedWeight) * 2.20462))
            weightUnit = .lbs
            selectedWeight = converted
        }
    }

    /// Toggles height unit between imperial and metric with conversion.
    private func toggleHeightUnit() {
        if heightUnit == .imperial {
            let totalInches = selectedFeet * 12 + selectedInches
            let cm = Int(round(Double(totalInches) * 2.54))
            selectedCm = cm
            heightUnit = .metric
        } else {
            let totalInches = Int(round(Double(selectedCm) / 2.54))
            let feet = totalInches / 12
            let inches = totalInches % 12
            selectedFeet = feet
            selectedInches = inches
            heightUnit = .imperial
        }
    }

    // MARK: - Transition Animation

    /// Animates a screen transition with fade + slide effect.
    private func animateTransition(forward: Bool, callback: @escaping () -> Void) {
        // Phase 1: Fade out and slide out
        withAnimation(.easeInOut(duration: 0.15)) {
            contentOpacity = 0
            contentOffset = forward ? -20 : 20
        }

        // Phase 2: Update content and position for entry
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            callback()
            contentOffset = forward ? 30 : -30

            // Phase 3: Fade in and slide in
            withAnimation(.easeInOut(duration: 0.3)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct BodyMeasurementScreensView_Previews: PreviewProvider {
    static var previews: some View {
        BodyMeasurementScreensView(
            onComplete: { _ in },
            onBack: {},
            currentStep: 5,
            totalSteps: 20
        )
    }
}
#endif
