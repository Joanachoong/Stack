import SwiftUI

/// Animated completion screen with checkmark animation
struct BaselineCompleteScreenView: View {
    let onComplete: () -> Void

    private let circleSize: CGFloat = 140
    private let strokeWidth: CGFloat = 8
    private let neonGreen = AppColors.primary

    private let listItems = [
        "Personal details collected",
        "Body metrics recorded",
        "Baseline established"
    ]

    @State private var circleProgress: CGFloat = 0
    @State private var showCheckmark = false
    @State private var titleOpacity: Double = 0
    @State private var itemOpacities: [Double] = [0, 0, 0]
    @State private var itemOffsets: [CGFloat] = [20, 20, 20]
    @State private var buttonOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.95
    @State private var iconOffset: CGFloat = 0

    private var radius: CGFloat {
        (circleSize - strokeWidth) / 2
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
                Spacer()

                // Animated icon group
                VStack(spacing: 20) {
                    ZStack {
                        // Circle
                        Circle()
                            .trim(from: 0, to: circleProgress * 0.92)
                            .stroke(neonGreen, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                            .frame(width: circleSize, height: circleSize)
                            .rotationEffect(.degrees(-90))

                        // Checkmark
                        if showCheckmark {
                            Image(systemName: "checkmark")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(neonGreen)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }

                    // Title
                    Text("Baseline Complete")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .opacity(titleOpacity)
                }
                .offset(y: iconOffset)
                .padding(.bottom, 20)

                // List items
                VStack(spacing: 20) {
                    ForEach(Array(listItems.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 16) {
                            // Bullet circle
                            
                            ZStack(){
                                Circle()
                                    .stroke(neonGreen, lineWidth: 4)
                                    .frame(width: 28, height: 28)
                                
                                if showCheckmark {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(neonGreen)
                                        .transition(.scale.combined(with: .opacity))
                                    
                                    
                                }
                            }
                            

                            Text(item)
                                .font(.system(size: 20)).bold()
                                .foregroundColor(.black)
                            Spacer()

                            
                        }
                        .opacity(itemOpacities[index])
                        .offset(y: itemOffsets[index])
                        .padding(.horizontal, 5)
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // Continue button
                PrimaryButton(title: "CONTINUE", action: onComplete)
                .opacity(buttonOpacity)
                .scaleEffect(buttonScale)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            animateSequence()
        }
    }

    private func animateSequence() {
        // Step 1: Draw circle (1.5s)
        withAnimation(.easeInOut(duration: 1.0)) {
            circleProgress = 1.0
        }

        // Step 2: Show checkmark + title
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showCheckmark = true
            }
            withAnimation(.easeIn(duration: 0.2).delay(0.6)) {
                titleOpacity = 1
            }
        }

        // Step 3: Staggered list items with icon moving up
        for i in 0..<listItems.count {
            let delay = 2.3 + Double(i) * 0.4
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.4)) {
                    itemOpacities[i] = 1
                    showCheckmark = true
                    itemOffsets[i] = 0
                    iconOffset = CGFloat((i + 1)) * -15
                }
            }
        }

        // Step 4: Show button
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
            withAnimation(.easeOut(duration: 0.4)) {
                buttonOpacity = 1
                buttonScale = 1.0
            }
        }
    }
}

#Preview {
    BaselineCompleteScreenView(onComplete: {})
}
