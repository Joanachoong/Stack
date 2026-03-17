/**
 * Risk Exposure Screen Component
 *
 * This component displays an animated risk gauge that visually demonstrates the dangers
 * of making unmonitored health optimization decisions. It serves as an educational
 * screen in the onboarding flow to emphasize the importance of professional guidance
 * when dealing with peptide and hormone therapies.
 *
 * Key features:
 * - Animated gauge with rotating needle showing escalating risk levels
 * - Orbiting warning arrow that moves around the gauge perimeter
 * - Pulsing warning triangle icon for attention-grabbing effect
 * - Gradient background transitioning from green (safe) to black (danger)
 * - Clear warning message about long-term risks of uninformed decisions
 *
 * The animation sequence demonstrates how risk accumulates over time without
 * proper monitoring, reinforcing the app's value proposition of guided optimization.
 */

import SwiftUI

// MARK: - AttentionTriangleShape

/// Warning triangle SVG component for attention-grabbing visual effect.
/// Converted from the AttentionTriangleSvg React component.
struct AttentionTriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scaleX = rect.width / 64
        let scaleY = rect.height / 64

        // Main triangle outline with exclamation mark cutout
        // fillRule: evenodd, clipRule: evenodd
        path.move(to: CGPoint(x: 31.9583 * scaleX, y: 5.08325 * scaleY))
        // Right side of triangle top curve
        path.addCurve(
            to: CGPoint(x: 34.1801 * scaleX, y: 6.39058 * scaleY),
            control1: CGPoint(x: 32.8814 * scaleX, y: 5.08325 * scaleY),
            control2: CGPoint(x: 33.7319 * scaleX, y: 5.58369 * scaleY)
        )
        // Right edge to bottom-right
        path.addLine(to: CGPoint(x: 59.5968 * scaleX, y: 52.1406 * scaleY))
        path.addCurve(
            to: CGPoint(x: 59.5656 * scaleX, y: 54.6639 * scaleY),
            control1: CGPoint(x: 60.0342 * scaleX, y: 52.9278 * scaleY),
            control2: CGPoint(x: 60.0223 * scaleX, y: 53.8877 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 57.375 * scaleX, y: 55.9166 * scaleY),
            control1: CGPoint(x: 59.1089 * scaleX, y: 55.44 * scaleY),
            control2: CGPoint(x: 58.2756 * scaleX, y: 55.9166 * scaleY)
        )
        // Bottom edge
        path.addLine(to: CGPoint(x: 6.54167 * scaleX, y: 55.9166 * scaleY))
        path.addCurve(
            to: CGPoint(x: 4.35108 * scaleX, y: 54.6639 * scaleY),
            control1: CGPoint(x: 5.6411 * scaleX, y: 55.9166 * scaleY),
            control2: CGPoint(x: 4.80778 * scaleX, y: 55.44 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 4.31985 * scaleX, y: 52.1406 * scaleY),
            control1: CGPoint(x: 3.89438 * scaleX, y: 53.8877 * scaleY),
            control2: CGPoint(x: 3.8825 * scaleX, y: 52.9278 * scaleY)
        )
        // Left edge back to top
        path.addLine(to: CGPoint(x: 29.7365 * scaleX, y: 6.39058 * scaleY))
        path.addCurve(
            to: CGPoint(x: 31.9583 * scaleX, y: 5.08325 * scaleY),
            control1: CGPoint(x: 30.1848 * scaleX, y: 5.58369 * scaleY),
            control2: CGPoint(x: 31.0353 * scaleX, y: 5.08325 * scaleY)
        )
        path.closeSubpath()

        // Inner triangle cutout (the hollow center)
        path.move(to: CGPoint(x: 10.8613 * scaleX, y: 50.8332 * scaleY))
        path.addLine(to: CGPoint(x: 53.0554 * scaleX, y: 50.8332 * scaleY))
        path.addLine(to: CGPoint(x: 31.9583 * scaleX, y: 12.8585 * scaleY))
        path.addLine(to: CGPoint(x: 10.8613 * scaleX, y: 50.8332 * scaleY))
        path.closeSubpath()

        // Exclamation mark bar (vertical rectangle)
        path.move(to: CGPoint(x: 31.9583 * scaleX, y: 22.8749 * scaleY))
        path.addCurve(
            to: CGPoint(x: 34.5 * scaleX, y: 25.4166 * scaleY),
            control1: CGPoint(x: 33.3621 * scaleX, y: 22.8749 * scaleY),
            control2: CGPoint(x: 34.5 * scaleX, y: 24.0129 * scaleY)
        )
        path.addLine(to: CGPoint(x: 34.5 * scaleX, y: 35.5833 * scaleY))
        path.addCurve(
            to: CGPoint(x: 31.9583 * scaleX, y: 38.1249 * scaleY),
            control1: CGPoint(x: 34.5 * scaleX, y: 36.987 * scaleY),
            control2: CGPoint(x: 33.3621 * scaleX, y: 38.1249 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 29.4167 * scaleX, y: 35.5833 * scaleY),
            control1: CGPoint(x: 30.5546 * scaleX, y: 38.1249 * scaleY),
            control2: CGPoint(x: 29.4167 * scaleX, y: 36.987 * scaleY)
        )
        path.addLine(to: CGPoint(x: 29.4167 * scaleX, y: 25.4166 * scaleY))
        path.addCurve(
            to: CGPoint(x: 31.9583 * scaleX, y: 22.8749 * scaleY),
            control1: CGPoint(x: 29.4167 * scaleX, y: 24.0129 * scaleY),
            control2: CGPoint(x: 30.5546 * scaleX, y: 22.8749 * scaleY)
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - RiskExposureScreenView

/**
 * Risk Exposure Screen Component
 *
 * Displays an animated risk gauge that demonstrates the accumulation of health risks
 * from unmonitored peptide/supplement decisions. The animation shows a needle moving
 * from safe to dangerous levels while a warning arrow orbits the gauge perimeter.
 *
 * The component uses complex animations to create an impactful visual metaphor:
 * - Needle rotation represents escalating risk levels
 * - Orbiting arrow shows risk circling/moving through danger zones
 * - Pulsing warning triangle emphasizes the cautionary message
 * - Gradient background transitions from green (safety) to black (danger)
 *
 * This screen serves as a psychological anchor point in the user journey,
 * making the value proposition of guided optimization more compelling.
 *
 * - Parameter onNext: Callback function to proceed to next screen
 */
struct RiskExposureScreenView: View {
    /// Callback function called when user taps the NEXT button
    var onNext: () -> Void
    
    // MARK: - Animation State
    
    /// Controls gauge needle position (maps to -90deg to +90deg rotation)
    @State private var needleRotation: Double = 0
    
    /// Controls warning triangle pulse effect (scale factor)
    @State private var triangleScale: Double = 1.0
    
    /// Controls orbiting arrow position (maps to rotation angle)
    @State private var trianglePosition: Double = 0
    
    /// Current phase of the animation sequence
    @State private var animationPhase: Int = 0
    
    /// Timer for managing the animation loop
    @State private var animationTimer: Timer? = nil
    
    // MARK: - Computed Properties
    
    /// Needle rotates from -90deg (safe) to +90deg (danger) based on risk level
    /// Convert animation values to rotation transforms for smooth visual movement
    private var needleAngle: Double {
        // Maps needleRotation (0-1) to angle (-90 to +90)
        -90.0 + needleRotation * 180.0
    }
    
    /// Triangle orbits around gauge perimeter through 4 key positions
    /// Maps abstract position values to actual rotation angles
    private var triangleAngle: Double {
        // Maps trianglePosition (0-3) to angle (-90 to +90)
        switch trianglePosition {
        case 0: return -90
        case 1: return -30
        case 2: return 30
        case 3: return 90
        default:
            // Linear interpolation between key positions
            let floor = Int(trianglePosition)
            let fraction = trianglePosition - Double(floor)
            let angles: [Double] = [-90, -30, 30, 90]
            let startAngle = angles[min(floor, 3)]
            let endAngle = angles[min(floor + 1, 3)]
            return startAngle + fraction * (endAngle - startAngle)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            LinearGradient(
                colors: [AppColors.primary.opacity(0.18), Color.clear],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.35)
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // MARK: Gauge Container
                GaugeView(needleAngle: needleAngle)
                
                // Pulsing warning triangle icon for visual impact
                AttentionTriangleShape()
                    .fill(Color(hex: "#EF4444").opacity(0.7))
                    .frame(width: 50, height: 50)
                    .overlay(
                        // Exclamation mark dot (ellipse at bottom of exclamation)
                        Ellipse()
                            .fill(Color(hex: "#A83030"))
                            .frame(width: 5.46, height: 5.21)
                            .offset(y: 11.5)
                    )
                    .scaleEffect(triangleScale)
                    .padding(.top, 10)
                
                // Core warning message about unmonitored decisions
                Text("Unmonitored decisions increase long-term risk.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.top, 10)
                    .padding(.horizontal, 42)
                
                Spacer()
                
                // Next button to proceed to budget questions
                PrimaryButton(title: "NEXT", action: onNext)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .padding(.top, 24)
            }
        }
        .onAppear {
            // Start the animation loop when component mounts
            runAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }
    
    // MARK: - Animation Methods
    
    /// Creates a pulsing animation for the warning triangle.
    /// Used to draw attention to the risk warning message.
    private func pulseTriangle() {
        withAnimation(.easeInOut(duration: 0.8)) {
            triangleScale = 2 // Scale up by 15% for attention-grabbing effect
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.8)) {
                triangleScale = 1.0 // Return to normal size
            }
        }
    }
    
    /// Animates both needle and triangle simultaneously to different positions.
    /// Creates the visual effect of risk escalating while the warning moves around the gauge.
    ///
    /// - Parameters:
    ///   - needleValue: Target rotation value for needle (0-1, maps to -90deg to 90deg)
    ///   - triangleValue: Target position for orbiting triangle (0-3, maps to gauge positions)
    ///   - duration: Animation duration in seconds
    ///   - overshoot: Optional overshoot amount for elastic effect on needle
    private func animateNeedleAndTriangle(
        needleValue: Double,
        triangleValue: Double,
        duration: Double,
        overshoot: Double = 0
    ) {
        // Needle animation with overshoot and elastic settling for realistic gauge movement
        withAnimation(.easeInOut(duration: 2.0)) {
            needleRotation = 1.0
        }
        
        // 30% of duration for settling at final position
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.7) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
                needleRotation = needleValue // Settle at final position
            }
        }
        
        // Triangle moves smoothly to new orbital position
        withAnimation(.easeOut(duration: duration)) {
            trianglePosition = triangleValue
        }
    }
    
    /// Main animation sequence that demonstrates risk escalation.
    /// Shows progressive movement from low to high risk, then resets.
    /// This creates the compelling narrative of accumulating danger.
    private func runAnimation() {
        // Initial pulse to grab attention
        pulseTriangle()
        withAnimation(.easeInOut(duration: 2.0)) {
            pulseTriangle()
            needleRotation = 1.0
        }
//        //        // Reset animation: Return to safe state dramatically
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.7) {
//            withAnimation(.easeIn(duration: 0.4)) {
//                pulseTriangle()
//                trianglePosition = 0 // Triangle back to start
//            }
//            
            // Recursively restart animation for continuous demonstration
            // Reset all animation values for seamless loop
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            triangleScale = 1.0
            runAnimation()
        }
        
    }
}


// MARK: - Preview

#Preview {
    RiskExposureScreenView(onNext: {})
}
