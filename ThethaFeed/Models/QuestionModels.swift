import Foundation

// MARK: - Option Variant

/// Visual style variant for question options.
///
/// Determines how each option is rendered in the multiple choice UI:
/// - `text`: Plain text option
/// - `numbered`: Option with a numeric prefix
/// - `intensity`: Option with an intensity level indicator
/// - `icon`: Option with a check/cross icon
enum OptionVariant: String, Codable {
    case text
    case numbered
    case intensity
    case icon
}

// MARK: - Icon Type

/// Icon types used for icon-variant question options.
///
/// Maps to the original TSX icon identifiers:
/// - `checkDouble`: Double check mark (strong affirmative)
/// - `check`: Single check mark (affirmative)
/// - `x`: Cross mark (negative)
enum IconType: String, Codable {
    case checkDouble = "check-double"
    case check
    case x
}

// MARK: - Intensity Level

/// Intensity level data for intensity-variant options.
///
/// Used to display a visual intensity indicator showing the current level
/// relative to the maximum possible level.
///
/// - Parameter level: Current intensity level
/// - Parameter maxLevel: Maximum possible intensity level
struct IntensityLevel: Codable, Equatable {
    let level: Int
    let maxLevel: Int
}

// MARK: - Question Option

/// Represents a single selectable option within a question.
///
/// - Parameter id: Unique identifier for the option
/// - Parameter label: Display text for the option
/// - Parameter variant: Visual style of the option (text, numbered, intensity, or icon)
/// - Parameter intensity: Intensity level data for intensity variant
/// - Parameter icon: Icon type for icon variant (check-double, check, or x)
struct QuestionOption: Identifiable, Codable, Equatable {
    let id: String
    let label: String
    let variant: OptionVariant?
    let intensity: IntensityLevel?
    let icon: IconType?

    init(id: String, label: String, variant: OptionVariant? = nil, intensity: IntensityLevel? = nil, icon: IconType? = nil) {
        self.id = id
        self.label = label
        self.variant = variant
        self.intensity = intensity
        self.icon = icon
    }
}

// MARK: - Question

/// Represents a single question in the questionnaire.
///
/// Each question contains an identifier, optional category, the question text,
/// whether multiple selections are allowed, and an array of possible answer options.
///
/// - Parameter id: Unique identifier for the question
/// - Parameter category: Optional category grouping for the question
/// - Parameter question: The actual question text displayed to the user
/// - Parameter multiSelect: Whether the question allows multiple selections
/// - Parameter options: Array of possible answer options
/// - Parameter options.id: Unique identifier for the option
/// - Parameter options.label: Display text for the option
/// - Parameter options.variant: Visual style of the option ('text' | 'numbered' | 'intensity' | 'icon')
/// - Parameter options.intensity: Intensity level data for intensity variant
/// - Parameter options.intensity.level: Current intensity level
/// - Parameter options.intensity.maxLevel: Maximum possible intensity level
/// - Parameter options.icon: Icon type for icon variant ('check-double' | 'check' | 'x')
struct Question: Identifiable, Codable, Equatable {
    let id: String
    let category: String?
    let question: String
    let multiSelect: Bool
    let options: [QuestionOption]

    init(id: String, category: String? = nil, question: String, multiSelect: Bool = false, options: [QuestionOption]) {
        self.id = id
        self.category = category
        self.question = question
        self.multiSelect = multiSelect
        self.options = options
    }
}

// MARK: - Screen State

/// Defines all possible screen states in the app's navigation flow.
///
/// The flow progresses through these states in a mostly linear fashion,
/// with some branching based on user responses and special interstitial screens.
enum ScreenState: String, CaseIterable {
    case splash
    case landing
    case disclaimers
    case progress
    case inputs
    case questionnaire
    case bodyMeasurements
    case preBaselineProgress
    case baselineComplete
    case failurePattern
    case riskExposure
    case sliderChoice
    case biologicalSummary
    case consent
    case outcomeProjection
    case mismatchConsequence
    case structuredGap
    case finalAnalysis
    case paywall
}

// MARK: - User Data

/// User profile data collected from input screens.
struct UserData: Equatable {
    let firstName: String
    let age: Int
}

// MARK: - Body Data

/// Body measurement data collected from body measurement screens.
struct BodyData: Equatable {
    let weight: Double
    let weightUnit: WeightUnit
    let height: Double
    let heightUnit: HeightUnit
}

/// Weight unit options.
enum WeightUnit: String, Codable {
    case lbs
    case kg
}

/// Height unit options.
enum HeightUnit: String, Codable {
    case imperial
    case metric
}

// MARK: - Summary Item

/// A single key-value pair for the biological summary display.
struct SummaryItem: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let value: String
}

// MARK: - Constants

/// Constants defining the number of screens in various multi-screen sections.
/// Used for accurate progress calculation across the entire onboarding flow.
let DISCLAIMER_SCREENS_COUNT = 5
let INPUT_SCREENS_COUNT = 2
let BODY_MEASUREMENT_SCREENS_COUNT = 2
let CONSENT_SCREENS_COUNT = 2
let SLIDER_CHOICE_SCREENS_COUNT = 2

// MARK: - Index Constants

/// Index constants for key questions that trigger screen transitions.
/// These indices correspond to positions in the QUESTIONS array and determine
/// when to switch from questionnaire to specialized screens (e.g., body measurements).
let GENDER_IDENTITY_INDEX = 0
let ETHNICITY_INDEX = 2
let NEEDLE_COMFORT_INDEX = 13
let BUDGET_INDEX = 14
let PROGRAM_TYPE_INDEX = 18 // After this, show Mismatch_Consequence
let TRAINING_INTENSITY_INDEX = 6 // After this, show Structured Gap
let CYCLING_EXPERIENCE_INDEX = 22

// MARK: - QuestionnaireConstants Namespace

/// Namespace enum providing access to questionnaire constants.
/// Used by QuestionnaireScreen for progress bar calculations.
enum QuestionnaireConstants {
    static let DISCLAIMER_SCREENS_COUNT = 5
    static let INPUT_SCREENS_COUNT = 2
    static let BODY_MEASUREMENT_SCREENS_COUNT = 2
    static let CONSENT_SCREENS_COUNT = 2
    static let SLIDER_CHOICE_SCREENS_COUNT = 2
    static let GENDER_IDENTITY_INDEX = 0
    static let ETHNICITY_INDEX = 2
    static let NEEDLE_COMFORT_INDEX = 13
    static let BUDGET_INDEX = 14
    static let PROGRAM_TYPE_INDEX = 18
    static let TRAINING_INTENSITY_INDEX = 6
    static let CYCLING_EXPERIENCE_INDEX = 22
    static let QUESTIONS = QUESTIONS_ARRAY
}

// MARK: - Questions Array

/// Comprehensive array of questions for the user assessment questionnaire.
///
/// This collection covers all aspects needed for personalized peptide/supplement recommendations:
/// - Demographics and biological factors
/// - Training and nutrition habits
/// - Health conditions and medical history
/// - Budget and comfort levels
/// - Experience with compounds and protocols
/// - Goals and expectations
///
/// Questions are ordered to create a logical flow from basic info to specific preferences.
/// Some questions trigger special screen transitions (e.g., body measurements after gender).
let QUESTIONS_ARRAY: [Question] = [
    // Question 0
    Question(
        id: "biological-sex",
        category: "Biological Sex",
        question: "What is your biological sex?",
        options: [
            QuestionOption(id: "male", label: "Male", variant: .numbered),
            QuestionOption(id: "female", label: "Female", variant: .numbered),
            QuestionOption(id: "intersex", label: "Intersex", variant: .numbered),
        ]
    ),
    // Question 1
    Question(
        id: "location",
        category: "Location",
        question: "Where do you live?",
        options: [
            QuestionOption(id: "us", label: "US", variant: .numbered),
            QuestionOption(id: "canada", label: "Canada", variant: .numbered),
            QuestionOption(id: "eu", label: "EU", variant: .numbered),
            QuestionOption(id: "uk", label: "UK", variant: .numbered),
            QuestionOption(id: "australia", label: "Australia", variant: .numbered),
            QuestionOption(id: "other", label: "Other", variant: .numbered),
        ]
    ),
    // Question 3  -consider remove  merge 3,4,6 into one question
    Question(
        id: "lifting-experience",
        category: "Lifting Experience",
        question: "How long have you been training seriously?",
        options: [
            QuestionOption(id: "less-1", label: "<1 year", variant: .numbered),
            QuestionOption(id: "1-2", label: "1\u{2013}2 years", variant: .numbered),
            QuestionOption(id: "3-5", label: "3\u{2013}5 years", variant: .numbered),
            QuestionOption(id: "5-plus", label: "5+ years", variant: .numbered),
        ]
    ),
    // Question 4  -consider remove
    Question(
        id: "training-frequency",
        category: "Training Frequency",
        question: "How often do you train per week?",
        options: [
            QuestionOption(id: "2-3", label: "2\u{2013}3 days", variant: .numbered),
            QuestionOption(id: "4", label: "4 days", variant: .numbered),
            QuestionOption(id: "5", label: "5 days", variant: .numbered),
            QuestionOption(id: "6-plus", label: "6+ days", variant: .numbered),
        ]
    ),
    // Question 5
    Question(
        id: "program-type",
        category: "Program Type",
        question: "What type of training do you follow?",
        options: [
            QuestionOption(id: "ppl", label: "PPL", variant: .numbered),
            QuestionOption(id: "bro-split", label: "Bro Split", variant: .numbered),
            QuestionOption(id: "upper-lower", label: "Upper/Lower", variant: .numbered),
            QuestionOption(id: "strength", label: "Strength-based", variant: .numbered),
            QuestionOption(id: "hybrid", label: "Hybrid", variant: .numbered),
            QuestionOption(id: "none", label: "No structured plan", variant: .numbered),
        ]
    ),
    // Question 6 -consider remove
    Question(
        id: "training-intensity",
        category: "Training Intensity",
        question: "How intense are your workouts?",
        options: [
            QuestionOption(id: "low", label: "Low", variant: .intensity, intensity: IntensityLevel(level: 1, maxLevel: 4)),
            QuestionOption(id: "moderate", label: "Moderate", variant: .intensity, intensity: IntensityLevel(level: 2, maxLevel: 4)),
            QuestionOption(id: "high", label: "High", variant: .intensity, intensity: IntensityLevel(level: 3, maxLevel: 4)),
            QuestionOption(id: "very-high", label: "Very High", variant: .intensity, intensity: IntensityLevel(level: 4, maxLevel: 4)),
        ]
    ),
    // Question 7
    Question(
        id: "nutrition-discipline",
        category: "Nutrition Discipline",
        question: "How consistent is your nutrition?",
        options: [
            QuestionOption(id: "very-inconsistent", label: "Very inconsistent", variant: .intensity, intensity: IntensityLevel(level: 1, maxLevel: 4)),
            QuestionOption(id: "somewhat-inconsistent", label: "Somewhat inconsistent", variant: .intensity, intensity: IntensityLevel(level: 2, maxLevel: 4)),
            QuestionOption(id: "mostly-consistent", label: "Mostly consistent", variant: .intensity, intensity: IntensityLevel(level: 3, maxLevel: 4)),
            QuestionOption(id: "very-consistent", label: "Very consistent", variant: .intensity, intensity: IntensityLevel(level: 4, maxLevel: 4)),
        ]
    ),
    // Question 8
    Question(
        id: "sleep-quality",
        category: "Sleep Quality",
        question: "How well do you sleep?",
        options: [
            QuestionOption(id: "poor", label: "Poor", variant: .intensity, intensity: IntensityLevel(level: 1, maxLevel: 4)),
            QuestionOption(id: "mixed", label: "Mixed", variant: .intensity, intensity: IntensityLevel(level: 2, maxLevel: 4)),
            QuestionOption(id: "good", label: "Good", variant: .intensity, intensity: IntensityLevel(level: 3, maxLevel: 4)),
            QuestionOption(id: "excellent", label: "Excellent", variant: .intensity, intensity: IntensityLevel(level: 4, maxLevel: 4)),
        ]
    ),
    // Question 9
    Question(
        id: "stress-levels",
        category: "Stress Levels",
        question: "How high is your daily stress?",
        options: [
            QuestionOption(id: "very-low", label: "Very low", variant: .numbered),
            QuestionOption(id: "low", label: "Low", variant: .numbered),
            QuestionOption(id: "moderate", label: "Moderate", variant: .numbered),
            QuestionOption(id: "high", label: "High", variant: .numbered),
            QuestionOption(id: "very-high", label: "Very high", variant: .numbered),
        ]
    ),
    // Question 10
    Question(
        id: "pre-existing-conditions",
        category: "Pre-Existing Conditions",
        question: "Do you have any pre-existing conditions?",
        multiSelect: true,
        options: [
            QuestionOption(id: "heart", label: "Heart issues", variant: .numbered),
            QuestionOption(id: "blood-pressure", label: "High blood pressure", variant: .numbered),
            QuestionOption(id: "anxiety-depression", label: "Anxiety/Depression", variant: .numbered),
            QuestionOption(id: "thyroid", label: "Thyroid issues", variant: .numbered),
            QuestionOption(id: "diabetes", label: "Diabetes", variant: .numbered),
            QuestionOption(id: "gi", label: "GI issues", variant: .numbered),
            QuestionOption(id: "none", label: "None", variant: .numbered),
        ]
    ),
    // Question 11 - important
    Question(
        id: "medical-supervision",
        category: "Medical Supervision",
        question: "Are you currently under medical supervision?",
        options: [
            QuestionOption(id: "yes", label: "Yes", variant: .icon, icon: .check),
            QuestionOption(id: "no", label: "No", variant: .icon, icon: .x),
        ]
    ),
    // Question 12 - important
    Question(
        id: "trt-hrt",
        category: "TRT/HRT",
        question: "Are you currently on TRT or HRT?",
        options: [
            QuestionOption(id: "yes", label: "Yes", variant: .icon, icon: .check),
            QuestionOption(id: "no", label: "No", variant: .icon, icon: .x),
            QuestionOption(id: "considering", label: "Considering it", variant: .numbered),
        ]
    ),
    // Question 13
    Question(
        id: "needle-comfort",
        category: "Comfort With Needles",
        question: "Are you comfortable with injections?",
        options: [
            QuestionOption(id: "no", label: "No", variant: .intensity, intensity: IntensityLevel(level: 1, maxLevel: 4)),
            QuestionOption(id: "slightly", label: "Slightly", variant: .intensity, intensity: IntensityLevel(level: 2, maxLevel: 4)),
            QuestionOption(id: "moderate", label: "Moderate", variant: .intensity, intensity: IntensityLevel(level: 3, maxLevel: 4)),
            QuestionOption(id: "very-comfortable", label: "Very comfortable", variant: .intensity, intensity: IntensityLevel(level: 4, maxLevel: 4)),
        ]
    ),
    // Question 14
    Question(
        id: "budget",
        category: "Budget",
        question: "What\u{2019}s your monthly budget for optimization?",
        options: [
            QuestionOption(id: "under-100", label: "<$100", variant: .numbered),
            QuestionOption(id: "100-200", label: "$100\u{2013}200", variant: .numbered),
            QuestionOption(id: "200-400", label: "$200\u{2013}400", variant: .numbered),
            QuestionOption(id: "400-plus", label: "$400+", variant: .numbered),
        ]
    ),
    // Question 15
    Question(
        id: "cycle-length",
        category: "Cycle Length Preference",
        question: "Are you open to longer protocols?",
        options: [
            QuestionOption(id: "4-6", label: "4\u{2013}6 weeks", variant: .numbered),
            QuestionOption(id: "8-12", label: "8\u{2013}12 weeks", variant: .numbered),
            QuestionOption(id: "12-plus", label: "12+ weeks", variant: .numbered),
        ]
    ),
    // Question 16 - important
    Question(
        id: "clinic-referral",
        category: "Clinic Referral",
        question: "Would you be open to a clinic referral?",
        options: [
            QuestionOption(id: "yes", label: "Yes", variant: .icon, icon: .check),
            QuestionOption(id: "maybe", label: "Maybe", variant: .numbered),
            QuestionOption(id: "no", label: "No", variant: .icon, icon: .x),
        ]
    ),
    // Question 17
    Question(
        id: "supplement-experience",
        category: "Supplement Experience",
        question: "Have you used supplements before?",
        options: [
            QuestionOption(id: "none", label: "None", variant: .intensity, intensity: IntensityLevel(level: 1, maxLevel: 4)),
            QuestionOption(id: "basic", label: "Basic", variant: .intensity, intensity: IntensityLevel(level: 2, maxLevel: 4)),
            QuestionOption(id: "intermediate", label: "Intermediate", variant: .intensity, intensity: IntensityLevel(level: 3, maxLevel: 4)),
            QuestionOption(id: "advanced", label: "Advanced", variant: .intensity, intensity: IntensityLevel(level: 4, maxLevel: 4)),
        ]
    ),
    // Question 18 - important
    Question(
        id: "peptide-experience",
        category: "Peptide Experience",
        question: "Have you used peptides before?",
        options: [
            QuestionOption(id: "no", label: "No", variant: .icon, icon: .x),
            QuestionOption(id: "yes-once", label: "Yes once", variant: .icon, icon: .check),
            QuestionOption(id: "yes-multiple", label: "Yes multiple times", variant: .icon, icon: .checkDouble),
        ]
    ),
    // Question 19
    Question(
        id: "administration-preference",
        category: "Administration Preference",
        question: "Preferred administration method?",
        options: [
            QuestionOption(id: "oral", label: "Oral only", variant: .numbered),
            QuestionOption(id: "injectable", label: "Injectable only", variant: .numbered),
            QuestionOption(id: "either", label: "Either", variant: .numbered),
            QuestionOption(id: "not-sure", label: "Not sure", variant: .numbered),
        ]
    ),
    // Question 20
    Question(
        id: "side-effects",
        category: "Side Effects",
        question: "Have you experienced side effects before?",
        multiSelect: true,
        options: [
            QuestionOption(id: "nausea", label: "Nausea", variant: .numbered),
            QuestionOption(id: "inflammation", label: "Inflammation", variant: .numbered),
            QuestionOption(id: "fatigue", label: "Fatigue", variant: .numbered),
            QuestionOption(id: "anxiety", label: "Anxiety", variant: .numbered),
            QuestionOption(id: "appetite", label: "Loss of appetite", variant: .numbered),
            QuestionOption(id: "other", label: "Other", variant: .numbered),
            QuestionOption(id: "none", label: "None", variant: .numbered),
        ]
    ),
    // Question 21 - important
    Question(
        id: "familiar-compounds",
        category: "Familiar Compounds",
        question: "Which compounds have you heard of?",
        multiSelect: true,
        options: [
            QuestionOption(id: "bpc-157", label: "BPC-157", variant: .numbered),
            QuestionOption(id: "tb-500", label: "TB-500", variant: .numbered),
            QuestionOption(id: "cjc-1295", label: "CJC-1295", variant: .numbered),
            QuestionOption(id: "ipamorelin", label: "Ipamorelin", variant: .numbered),
            QuestionOption(id: "mk-677", label: "MK-677", variant: .numbered),
            QuestionOption(id: "nad", label: "NAD+", variant: .numbered),
            QuestionOption(id: "collagen", label: "Collagen", variant: .numbered),
            QuestionOption(id: "gh-boosters", label: "GH boosters", variant: .numbered),
            QuestionOption(id: "other", label: "Other", variant: .numbered),
        ]
    ),
    // Question 22
    Question(
        id: "cycling-experience",
        category: "Cycling Experience",
        question: "Have you ever followed a structured cycle?",
        options: [
            QuestionOption(id: "no", label: "No", variant: .icon, icon: .x),
            QuestionOption(id: "yes-once", label: "Yes once", variant: .icon, icon: .check),
            QuestionOption(id: "yes-multiple", label: "Yes multiple cycles", variant: .icon, icon: .checkDouble),
        ]
    ),
    // Question 23 - important just ask goal
    Question(
        id: "primary-goal",
        category: "Primary Goal",
        question: "What is your primary goal?",
        options: [
            QuestionOption(id: "muscle-gain", label: "Muscle gain", variant: .numbered),
            QuestionOption(id: "fat-loss", label: "Fat loss", variant: .numbered),
            QuestionOption(id: "recomposition", label: "Recomposition", variant: .numbered),
            QuestionOption(id: "recovery", label: "Recovery", variant: .numbered),
            QuestionOption(id: "longevity", label: "Longevity", variant: .numbered),
        ]
    ),
    // Question 24
    Question(
        id: "timeline-expectation",
        category: "Timeline Expectation",
        question: "How fast do you want results?",
        options: [
            QuestionOption(id: "slow", label: "Slow", variant: .intensity, intensity: IntensityLevel(level: 1, maxLevel: 4)),
            QuestionOption(id: "sustainable", label: "Sustainable", variant: .intensity, intensity: IntensityLevel(level: 2, maxLevel: 4)),
            QuestionOption(id: "moderate", label: "Moderate", variant: .intensity, intensity: IntensityLevel(level: 3, maxLevel: 4)),
            QuestionOption(id: "aggressive", label: "Aggressive", variant: .intensity, intensity: IntensityLevel(level: 4, maxLevel: 4)),
        ]
    ),
    // Question 25
    Question(
        id: "obstacles",
        category: "Obstacles",
        question: "What\u{2019}s your biggest challenge right now?",
        options: [
            QuestionOption(id: "consistency", label: "Consistency", variant: .numbered),
            QuestionOption(id: "diet", label: "Diet", variant: .numbered),
            QuestionOption(id: "time", label: "Time", variant: .numbered),
            QuestionOption(id: "knowledge", label: "Knowledge", variant: .numbered),
            QuestionOption(id: "stress", label: "Stress", variant: .numbered),
            QuestionOption(id: "sleep", label: "Sleep", variant: .numbered),
            QuestionOption(id: "recovery", label: "Recovery", variant: .numbered),
        ]
    ),
]
