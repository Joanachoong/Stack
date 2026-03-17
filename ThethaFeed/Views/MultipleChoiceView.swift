import SwiftUI

// MARK: - IntensityBars View

struct IntensityBars: View {
    let level: Int
    let maxLevel: Int
    let isSelected: Bool

    private let heights: [CGFloat] = [10, 15, 20, 25]

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 73)
                    .fill(index < level ? AppColors.primary : (isSelected ? AppColors.primaryDark : AppColors.primaryMuted))
                    .frame(width: 5, height: heights[index])
            }
        }
        .frame(width: 40)
    }
}

// MARK: - OptionIcon View

struct OptionIcon: View {
    let type: IconType

    var body: some View {
        switch type {
        case .checkDouble:
            ZStack {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.success)
                    .offset(x: -5)
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.success)
                    .offset(x: 5)
            }
        case .check:
            Image(systemName: "checkmark")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.successDark)
        case .x:
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.danger)
        }
    }
}

// MARK: - OptionCard View

struct OptionCard: View {
    let option: QuestionOption
    let index: Int
    let isSelected: Bool
    let onPress: () -> Void
    var multiSelect: Bool = false

    var body: some View {
        Button(action: onPress) {
            ZStack(alignment: .top) {
                // Card body
                HStack(spacing: 12) {
                    HStack(spacing: 12) {
                        // Numbered variant
                        if option.variant == .numbered {
                            Text("\(index + 1).")
                                .font(.system(size: 20, weight: .bold))
                                .tracking(1)
                                .foregroundColor(isSelected ? .white : .black)
                                .frame(width: 30, alignment: .leading)
                        }

                        // Intensity variant
                        if option.variant == .intensity, let intensity = option.intensity {
                            IntensityBars(
                                level: intensity.level,
                                maxLevel: intensity.maxLevel,
                                isSelected: isSelected
                            )
                        }

                        // Icon variant
                        if option.variant == .icon, let iconType = option.icon {
                            OptionIcon(type: iconType)
                                .frame(width: 36, height: 36)
                        }

                        // Label text — weight 400 unselected / 600 selected
                        Text(option.label)
                            .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                            .foregroundColor(isSelected ? .white : .black)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    // Selector — checkbox (multi) or diamond radio (single)
                    if multiSelect {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(isSelected ? .white : AppColors.textMuted, lineWidth: 1.5)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(isSelected ? .white : Color.clear)
                                )
                                .frame(width: 22, height: 22)

                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding(.leading, 8)
                    } else {
                        // Diamond radio: 16×16 RoundedRect rotated 45°
                        ZStack {
                            RoundedRectangle(cornerRadius: 3)
                                .strokeBorder(isSelected ? .white : AppColors.textMuted, lineWidth: 1.5)
                                .frame(width: 14, height: 14)
                                .rotationEffect(.degrees(45))

                            if isSelected {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.white)
                                    .frame(width: 8, height: 8)
                                    .rotationEffect(.degrees(45))
                            }
                        }
                        .frame(width: 22, height: 22)
                        .padding(.leading, 8)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 25)

                // Top glow edge — 1px line across full width when selected
                if isSelected {
                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                        .frame(height: 1)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? AppColors.primary : Color(hex: "#98F1AC"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? AppColors.primary : AppColors.border, lineWidth: 1)
            )
            .shadow(color: isSelected ? AppColors.primary.opacity(0.12) : .clear, radius: 12, x: 0, y: 0)
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(OptionCardButtonStyle())
    }
}

// MARK: - OptionCard Button Style

struct OptionCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - MultipleChoiceView

struct MultipleChoiceView: View {
    var category: String? = nil
    let question: String
    let options: [QuestionOption]
    let currentStep: Int
    let totalSteps: Int
    var selectedId: String? = nil
    var selectedIds: [String] = []
    var multiSelect: Bool = false
    let onSelect: (String) -> Void
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var contentOpacity: Double = 1.0
    @State private var contentOffset: CGFloat = 0
    @State private var isAnimating: Bool = false

    @State private var displayedCategory: String? = nil
    @State private var displayedQuestion: String = ""
    @State private var displayedOptions: [QuestionOption] = []
    @State private var displayedStep: Int = 0
    @State private var prevStep: Int = 0

    private var isNextDisabled: Bool {
        selectedId == nil && selectedIds.isEmpty
    }

    private var progressFraction: CGFloat {
        CGFloat(currentStep) / CGFloat(totalSteps)
    }

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
                    // MARK: Header
                    VStack(spacing: 14) {
                        // Progress bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 9999)
                                .fill(AppColors.progressTrack)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 9999)
                                .fill(AppColors.primary)
                                .frame(width: progressFraction * (geometry.size.width - 48), height: 4)
                                .shadow(color: AppColors.primary.opacity(0.6), radius: 6, x: 0, y: 0)
                                .animation(.easeOut(duration: 0.2), value: currentStep)
                        }

                        // Header row: back button + step badge
                        HStack {
                            // Back button: 42×42, cornerRadius 14, surface bg + border
                            Button(action: onBack) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.text)
                                    .frame(width: 42, height: 42)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(AppColors.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .strokeBorder(AppColors.border, lineWidth: 1)
                                            )
                                    )
                            }

                            Spacer()

                            // Step badge: 14px H / 6px V, cornerRadius 20, border
                            Text("\(currentStep) of \(totalSteps)")
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
                    .padding(.top, geometry.safeAreaInsets.top + 8)

                    // MARK: Scrollable content — question + options
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Question container
                            VStack(alignment: .leading, spacing: 0) {
                                // Category badge
                                if let cat = displayedCategory {
                                    Text(cat.uppercased())
                                        .font(.system(size: 12, weight: .bold))
                                        .tracking(2)
                                        .foregroundColor(AppColors.primary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(AppColors.primary.opacity(0.10))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .strokeBorder(AppColors.primary.opacity(0.30), lineWidth: 1)
                                                )
                                        )
                                        .padding(.bottom, 12)
                                }

                                // Question text: 28px, weight 800, tracking -0.3, lineSpacing 8
                                Text(displayedQuestion)
                                    .font(.system(size: 28, weight: .heavy))
                                    .tracking(-0.3)
                                    .foregroundColor(.black)
                                    .lineSpacing(8)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.bottom, 12)

                                // Multi-select hint
                                if multiSelect {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.primary)
                                        Text("Select all that apply")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(AppColors.textMuted)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(AppColors.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(AppColors.border, lineWidth: 1)
                                            )
                                    )
                                    .padding(.bottom, 4)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)

                            // Options list — 10px gap between cards
                            VStack(spacing: 10) {
                                ForEach(Array(displayedOptions.enumerated()), id: \.element.id) { index, option in
                                    OptionCard(
                                        option: option,
                                        index: index,
                                        isSelected: multiSelect
                                            ? selectedIds.contains(option.id)
                                            : selectedId == option.id,
                                        onPress: {
                                            if !isAnimating { onSelect(option.id) }
                                        },
                                        multiSelect: multiSelect
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                        }
                    }
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                    // MARK: Footer — Continue button
                    Button(action: onNext) {
                        Text("CONTINUE")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 57)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                            .shadow(
                                color: isNextDisabled ? .clear : AppColors.primary.opacity(0.35),
                                radius: 18, x: 0, y: 0
                            )
                    }
                    .disabled(isNextDisabled)
                    .opacity(isNextDisabled ? 0.5 : 1.0)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            displayedCategory = category
            displayedQuestion = question
            displayedOptions = options
            displayedStep = currentStep
            prevStep = currentStep
        }
        .onChange(of: currentStep) { newStep in
            guard newStep != prevStep else { return }

            let isForward = newStep > prevStep
            isAnimating = true

            withAnimation(.easeInOut(duration: 0.15)) {
                contentOpacity = 0
                contentOffset = isForward ? -20 : 20
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                displayedCategory = category
                displayedQuestion = question
                displayedOptions = options
                displayedStep = newStep
                contentOffset = isForward ? 30 : -30

                withAnimation(.easeInOut(duration: 0.3)) {
                    contentOpacity = 1.0
                    contentOffset = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAnimating = false
                }
            }

            prevStep = newStep
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MultipleChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        MultipleChoiceView(
            category: "Lifestyle",
            question: "How often do you exercise?",
            options: [
                QuestionOption(id: "1", label: "Never", variant: .numbered),
                QuestionOption(id: "2", label: "1-2 times a week", variant: .numbered),
                QuestionOption(id: "3", label: "3-4 times a week", variant: .numbered),
                QuestionOption(id: "4", label: "5+ times a week", variant: .numbered),
            ],
            currentStep: 3,
            totalSteps: 20,
            selectedId: "2",
            onSelect: { _ in },
            onNext: {},
            onBack: {}
        )
    }
}
#endif
