import SwiftUI

/// Main questionnaire view model for ThethaFeed app.
///
/// This view model orchestrates a multi-step onboarding and assessment process for users
/// seeking personalized peptide and supplement recommendations. It manages state transitions
/// between various screens including splash, landing, disclaimers, user inputs, body measurements,
/// a comprehensive questionnaire, risk assessments, and final analysis/paywall.
///
/// The questionnaire collects detailed user information about demographics, training history,
/// health conditions, budget, and goals to provide tailored optimization protocols.
///
/// Key features:
/// - Animated transitions between screens for smooth UX
/// - Support for single and multi-select questions
/// - Progress tracking through the entire onboarding flow
/// - Integration with backend scoring system for personalized recommendations
/// - Paywall integration for premium features
///
/// This view model serves as the central hub for the app's user experience, handling:
/// - State management for screen navigation and user responses
/// - Animated transitions between different screens
/// - Progress tracking and step calculation
/// - Integration with various specialized screen components
/// - Data collection and preparation for backend analysis
///
/// The view model uses a state machine approach with screenState to manage the complex
/// flow between questionnaire questions, specialized screens, and final analysis.
class QuestionnaireViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Core state management for the questionnaire flow
    @Published var screenState: ScreenState = .splash // <- CHANGE THIS LINE FOR CHANGING TO THE CURRENT SCREEN

    @Published var currentQuestionIndex: Int = 0

    /// User response storage - separated for single vs multi-select questions
    @Published var answers: [String: String] = [:]
    @Published var multiAnswers: [String: [String]] = [:]

    /// User profile data collected from input screens
    @Published var userData: UserData? = nil
    @Published var bodyData: BodyData? = nil

    // MARK: - Computed Properties

    /// Derived state for current question
    var currentQuestion: Question {
        QUESTIONS_ARRAY[currentQuestionIndex]
    }

    /// Currently selected option ID for single-select questions
    var selectedId: String? {
        answers[currentQuestion.id]
    }

    /// Currently selected option IDs for multi-select questions
    var selectedIds: [String] {
        multiAnswers[currentQuestion.id] ?? []
    }

    /// Calculate total steps for progress tracking.
    /// Includes only: inputs (name + age) + body measurements (weight + height) + questions
    /// Excludes: disclaimers, slider choice, consent, animation screens
    var totalSteps: Int {
        INPUT_SCREENS_COUNT + BODY_MEASUREMENT_SCREENS_COUNT + QUESTIONS_ARRAY.count
    }

    /// Helper to look up the human-readable label for a question answer.
    /// Maps from answer ID (e.g., 'female') to display label (e.g., 'Female')
    /// by searching the QUESTIONS array for the matching question and option.
    ///
    /// - Parameter questionId: The question's unique ID from QUESTIONS array
    /// - Returns: The option label, or "N/A" if no answer exists
    func getAnswerLabel(_ questionId: String) -> String {
        guard let answerId = answers[questionId] else { return "N/A" }
        guard let question = QUESTIONS_ARRAY.first(where: { $0.id == questionId }) else { return answerId }
        guard let option = question.options.first(where: { $0.id == answerId }) else { return answerId }
        return option.label
    }

    /// Pre-formatted summary items for the BiologicalSummary card
    var summaryItems: [SummaryItem] {
        [
            SummaryItem(label: "Name", value: userData?.firstName ?? "N/A"),
            SummaryItem(label: "Age", value: userData?.age != nil ? String(userData!.age) : "N/A"),
            SummaryItem(label: "Biological Sex", value: getAnswerLabel("biological-sex")),
            SummaryItem(label: "Gender", value: getAnswerLabel("gender-identity")),
            SummaryItem(
                label: "Weight",
                value: bodyData != nil
                    ? "\(bodyData!.weight) \(bodyData!.weightUnit.rawValue)"
                    : "N/A"
            ),
            SummaryItem(
                label: "Height",
                value: bodyData != nil
                    ? "\(bodyData!.height) \(bodyData!.heightUnit == .imperial ? "in" : "cm")"
                    : "N/A"
            ),
            SummaryItem(label: "Location", value: getAnswerLabel("location")),
        ]
    }

    // MARK: - Handler Methods

    /// Handles user selection of an answer option.
    ///
    /// For single-select questions, replaces the current selection.
    /// For multi-select questions, toggles the selection on/off.
    ///
    /// - Parameter id: The ID of the selected option
    func handleSelect(_ id: String) {
        if currentQuestion.multiSelect {
            var current = multiAnswers[currentQuestion.id] ?? []
            if let index = current.firstIndex(of: id) {
                current.remove(at: index)
            } else {
                current.append(id)
            }
            multiAnswers[currentQuestion.id] = current
        } else {
            answers[currentQuestion.id] = id
        }
    }

    /// Handles progression to the next screen or question.
    ///
    /// Contains complex branching logic to determine the next state based on:
    /// - Current question index (triggers special screen transitions)
    /// - Whether we're at the end of the questionnaire
    /// - User responses that require additional information gathering
    ///
    /// Key transition points:
    /// - After gender identity: body measurements
    /// - After ethnicity: baseline progress
    /// - After needle comfort: risk exposure assessment
    /// - After program type: mismatch consequence explanation
    /// - After cycling experience: outcome projection
    /// - End of questionnaire: consent screens
    func handleNext() {
        // Special transition: After gender identity question, collect body measurements
        // This ensures we have baseline metrics before proceeding with health questions
        if currentQuestionIndex == GENDER_IDENTITY_INDEX {
            withAnimation(.easeInOut(duration: 0.3)) {
                screenState = .bodyMeasurements
            }
        } else if currentQuestionIndex == ETHNICITY_INDEX {
            // After ethnicity, show biological summary review before baseline
            // Lets the user verify their demographic data before proceeding
            withAnimation(.easeInOut(duration: 0.3)) {
                screenState = .biologicalSummary
            }
        } else if currentQuestionIndex == NEEDLE_COMFORT_INDEX {
            // After needle comfort assessment, show risk exposure screen
            // Important for informed consent regarding injection-based protocols
            withAnimation(.easeInOut(duration: 0.3)) {
                screenState = .riskExposure
            }
        } else if currentQuestionIndex == TRAINING_INTENSITY_INDEX {
            // After training intensity, show structured gap screen before nutrition discipline
            withAnimation(.easeInOut(duration: 0.3)) {
                screenState = .structuredGap
            }
        } else if currentQuestionIndex == PROGRAM_TYPE_INDEX {
            // After program type, explain potential consequences of training mismatches
            // Educates user about risks of improper peptide use with certain training styles
            withAnimation(.easeInOut(duration: 0.3)) {
                screenState = .mismatchConsequence
            }
        } else if currentQuestionIndex == CYCLING_EXPERIENCE_INDEX {
            // After cycling experience, show outcome projections
            // Helps set realistic expectations based on user's experience level
            withAnimation(.easeInOut(duration: 0.3)) {
                screenState = .outcomeProjection
            }
        } else if currentQuestionIndex < QUESTIONS_ARRAY.count - 1 {
            // Standard question progression with smooth animation
            withAnimation(.easeInOut(duration: 0.25)) {
                currentQuestionIndex += 1
            }
        } else {
            // End of questionnaire - transition to consent and final analysis
            withAnimation(.easeInOut(duration: 0.3)) {
                screenState = .consent
            }
            print("Final answers:", answers.merging(multiAnswers.mapValues { $0.joined(separator: ", ") }) { _, new in new })
        }
    }

    /// Handles back navigation within the questionnaire.
    /// Moves to previous question if not at the beginning.
    func handleBack() {
        if currentQuestionIndex > 0 {
            // Smooth transition when going back between questions
            withAnimation(.easeInOut(duration: 0.25)) {
                currentQuestionIndex -= 1
            }
        }
    }

    /// Handles completion of splash screen animation.
    /// Transitions to landing screen to begin user onboarding.
    func handleSplashFinish() {
        withAnimation(.easeInOut(duration: 0.4)) {
            screenState = .landing
        }
    }

    /// Handles user selection to get started with the assessment.
    /// Transitions from landing to disclaimer screens.
    func handleGetStarted() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .disclaimers
        }
    }

    /// Handles completion of disclaimer screens.
    /// Advances to user input collection (name, age).
    func handleDisclaimersComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .inputs
        }
    }

    /// Handles completion of progress screen.
    /// Used for transitional loading states between sections.
    func handleProgressComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .inputs
        }
    }

    /// Handles completion of user input screens.
    /// Stores user data and transitions to questionnaire.
    ///
    /// - Parameter data: User input data containing firstName and age
    func handleInputsComplete(data: UserData) {
        userData = data
        print("User data:", data)
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .questionnaire
        }
    }

    /// Handles back navigation from input screens.
    /// Returns to disclaimer screens.
    func handleInputsBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .disclaimers
        }
    }

    /// Handles completion of consent screens.
    /// Transitions to the final analysis screen.
    func handleConsentComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .finalAnalysis
        }
    }

    /// Handles completion of final analysis screen.
    /// Transitions to the paywall screen.
    func handleFinalAnalysisComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .paywall
        }
    }

    /// Handles back navigation from consent screens.
    /// Returns to the last question in the questionnaire.
    func handleConsentBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .questionnaire
            currentQuestionIndex = QUESTIONS_ARRAY.count - 1
        }
    }

    /// Handles completion of body measurement screens.
    /// Stores body data and resumes questionnaire after gender identity.
    ///
    /// - Parameter data: Body measurement data containing weight, weightUnit, height, heightUnit
    func handleBodyMeasurementsComplete(data: BodyData) {
        bodyData = data
        print("Body data:", data)
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .questionnaire
            currentQuestionIndex = GENDER_IDENTITY_INDEX + 1
        }
    }

    /// Handles completion of baseline complete screen.
    /// Transitions to failure pattern assessment.
    func handleBaselineComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .failurePattern
        }
    }

    /// Handles completion of failure pattern screen.
    /// Resumes questionnaire after ethnicity question.
    func handleFailurePatternComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .questionnaire
            currentQuestionIndex = ETHNICITY_INDEX + 1
        }
    }

    /// Handles completion of biological summary review screen.
    /// Transitions to the pre-baseline progress screen, continuing the
    /// original ethnicity -> progress -> baseline -> failure pattern flow.
    func handleBiologicalSummaryComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .preBaselineProgress
        }
    }

    /// Handles completion of risk exposure screen.
    /// Transitions to slider choice screens (Risk Tolerance + Motivation)
    /// before resuming the questionnaire.
    func handleRiskExposureComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .sliderChoice
        }
    }

    /// Handles completion of slider choice screens (Risk Tolerance + Motivation).
    /// Resumes questionnaire at the budget question after slider assessments.
    func handleSliderChoiceComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .questionnaire
            currentQuestionIndex = BUDGET_INDEX
        }
    }

    /// Handles back navigation from slider choice screens.
    /// Returns to the risk exposure screen.
    func handleSliderChoiceBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .riskExposure
        }
    }

    /// Handles completion of structured gap screen.
    /// Resumes questionnaire at nutrition discipline (question after training intensity).
    func handleStructuredGapComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .questionnaire
            currentQuestionIndex = TRAINING_INTENSITY_INDEX + 1 // Go to Nutrition Discipline
        }
    }

    /// Handles completion of mismatch consequence screen.
    /// Resumes questionnaire after program type question.
    func handleMismatchConsequenceComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .questionnaire
            currentQuestionIndex = PROGRAM_TYPE_INDEX + 1 // Go to Training Intensity (question 19)
        }
    }

    /// Handles completion of outcome projection screen.
    /// Resumes questionnaire after cycling experience question.
    func handleOutcomeProjectionComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .questionnaire
            currentQuestionIndex = CYCLING_EXPERIENCE_INDEX + 1 // Go to Primary Goal (question 38)
        }
    }

    /// Handles back navigation from body measurements.
    /// Returns to gender identity question.
    func handleBodyMeasurementsBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .questionnaire
            currentQuestionIndex = GENDER_IDENTITY_INDEX
        }
    }

    /// Placeholder for sign-in functionality.
    /// Currently shows an alert as feature is not yet implemented.
    func handleSignIn() {
        // Sign in functionality coming soon
        print("Sign In: Sign in functionality coming soon!")
    }

    /// Handles user starting their premium membership.
    /// Logs all collected data for backend processing.
    func handleStartMembership() {
        print("Welcome! Your membership has started. Thank you for joining!")
        print("Membership started with answers:", userData as Any, bodyData as Any, answers, multiAnswers)
    }

    /// Handles closing the paywall and returning to questionnaire.
    /// Allows users to continue without premium features.
    func handleClosePaywall() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .questionnaire
        }
    }

    /// Handles the pre-baseline progress screen completion.
    /// Transitions from the pre-baseline progress to the baseline complete screen.
    func handlePreBaselineProgressComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screenState = .baselineComplete
        }
    }
}
