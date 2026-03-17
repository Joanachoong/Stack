/**
 * Main questionnaire screen component for ThethaFeed app.
 *
 * This component orchestrates a multi-step onboarding and assessment process for users
 * seeking personalized peptide and supplement recommendations. It manages state transitions
 * between various screens including splash, landing, disclaimers, user inputs, body measurements,
 * a comprehensive questionnaire, risk assessments, and final analysis/paywall.
 *
 * The questionnaire collects detailed user information about demographics, training history,
 * health conditions, budget, and goals to provide tailored optimization protocols.
 *
 * Key features:
 * - Animated transitions between screens for smooth UX
 * - Support for single and multi-select questions
 * - Progress tracking through the entire onboarding flow
 * - Integration with backend scoring system for personalized recommendations
 * - Paywall integration for premium features
 */

import SwiftUI

/// Main questionnaire component that manages the entire user onboarding and assessment flow.
///
/// This view serves as the central hub for the app's user experience, handling:
/// - State management for screen navigation and user responses
/// - Animated transitions between different screens
/// - Progress tracking and step calculation
/// - Integration with various specialized screen components
/// - Data collection and preparation for backend analysis
///
/// The component uses a state machine approach with screenState to manage the complex
/// flow between questionnaire questions, specialized screens, and final analysis.
struct QuestionnaireScreen: View {
    @StateObject private var viewModel = QuestionnaireViewModel()

    var body: some View {
        ZStack {
            // Render different screens based on current state in the onboarding flow
            // Each screen handles a specific part of the user assessment process
            switch viewModel.screenState {
            case .splash:
                SplashScreenView(onFinish: viewModel.handleSplashFinish)
                    .transition(.opacity)

            case .landing:
                LandingScreenView(
                    onGetStarted: viewModel.handleGetStarted,
                    onSignIn: viewModel.handleSignIn
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .disclaimers:
                // Calculate total steps for progress tracking across the entire onboarding flow
                // Includes: disclaimers + inputs + body measurements + questions + consent + final analysis
                DisclaimerScreensView(
                    onComplete: viewModel.handleDisclaimersComplete,
                    totalOnboardingSteps: viewModel.totalSteps
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .progress:
                ProgressScreenView(onComplete: viewModel.handleProgressComplete)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .inputs:
                InputScreensView(
                    onComplete: viewModel.handleInputsComplete,
                    onBack: viewModel.handleInputsBack,
                    currentStep: 1,
                    totalSteps: viewModel.totalSteps
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .bodyMeasurements:
                let bodyMeasurementStep = QuestionnaireConstants.INPUT_SCREENS_COUNT + QuestionnaireConstants.GENDER_IDENTITY_INDEX + 2
                BodyMeasurementScreensView(
                    onComplete: viewModel.handleBodyMeasurementsComplete,
                    onBack: viewModel.handleBodyMeasurementsBack,
                    currentStep: bodyMeasurementStep,
                    totalSteps: viewModel.totalSteps
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .biologicalSummary:
                /// Helper to look up the human-readable label for a question answer.
                /// Maps from answer ID (e.g., 'female') to display label (e.g., 'Female')
                /// by searching the QUESTIONS array for the matching question and option.
                BiologicalSummaryView(
                    onComplete: viewModel.handleBiologicalSummaryComplete,
                    items: viewModel.summaryItems
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .preBaselineProgress:
                ProgressScreenView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.screenState = .baselineComplete
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .baselineComplete:
                BaselineCompleteScreenView(onComplete: viewModel.handleBaselineComplete)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .failurePattern:
                FailurePatternView(onComplete: viewModel.handleFailurePatternComplete)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .riskExposure:
                RiskExposureScreenView(onNext: viewModel.handleRiskExposureComplete)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .sliderChoice:
                let sliderChoiceStep = QuestionnaireConstants.DISCLAIMER_SCREENS_COUNT + QuestionnaireConstants.INPUT_SCREENS_COUNT + QuestionnaireConstants.BODY_MEASUREMENT_SCREENS_COUNT + QuestionnaireConstants.NEEDLE_COMFORT_INDEX + 2
                SliderChoiceView(
                    onComplete: viewModel.handleSliderChoiceComplete,
                    onBack: viewModel.handleSliderChoiceBack,
                    currentStep: sliderChoiceStep,
                    totalSteps: viewModel.totalSteps
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .mismatchConsequence:
                MismatchConsequenceView(onComplete: viewModel.handleMismatchConsequenceComplete)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .structuredGap:
                StructuredGapView(onNext: viewModel.handleStructuredGapComplete)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .outcomeProjection:
                OutcomeProjectionView(onComplete: viewModel.handleOutcomeProjectionComplete)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .consent:
                ConsentScreensView(
                    onComplete: viewModel.handleConsentComplete,
                    onBack: viewModel.handleConsentBack,
                    currentStep: QuestionnaireConstants.DISCLAIMER_SCREENS_COUNT + QuestionnaireConstants.INPUT_SCREENS_COUNT + QuestionnaireConstants.BODY_MEASUREMENT_SCREENS_COUNT + QuestionnaireConstants.QUESTIONS.count + 1,
                    totalSteps: viewModel.totalSteps
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .finalAnalysis:
                FinalAnalysisView(onComplete: viewModel.handleFinalAnalysisComplete)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .paywall:
                PaywallScreenView(
                    onClose: viewModel.handleClosePaywall,
                    onStartMembership: viewModel.handleStartMembership,
                    currentStep: viewModel.totalSteps,
                    totalSteps: viewModel.totalSteps
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .questionnaire:
                // Default questionnaire view showing multiple choice questions
                MultipleChoiceView(
                    category: viewModel.currentQuestion.category,
                    question: viewModel.currentQuestion.question,
                    options: viewModel.currentQuestion.options,
                    // Calculate current step for progress bar - accounts for screens completed before questionnaire
                    // Before body measurements: disclaimers + inputs + current question index
                    // After body measurements: add body measurement screens to the count
                    currentStep: viewModel.currentQuestionIndex <= QuestionnaireConstants.GENDER_IDENTITY_INDEX
                        ? viewModel.currentQuestionIndex + QuestionnaireConstants.INPUT_SCREENS_COUNT + 1
                        : viewModel.currentQuestionIndex + QuestionnaireConstants.INPUT_SCREENS_COUNT + QuestionnaireConstants.BODY_MEASUREMENT_SCREENS_COUNT + 1,
                    totalSteps: viewModel.totalSteps,
                    selectedId: viewModel.selectedId,
                    selectedIds: viewModel.selectedIds,
                    multiSelect: viewModel.currentQuestion.multiSelect,
                    onSelect: viewModel.handleSelect,
                    onNext: viewModel.handleNext,
                    onBack: viewModel.handleBack
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.screenState)
    }
}

#Preview {
    QuestionnaireScreen()
        .preferredColorScheme(.dark)
}
