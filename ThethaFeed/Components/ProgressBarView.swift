import SwiftUI

/// Reusable animated progress bar used across multiple screens
struct ProgressBarView: View {
    let current: Int
    let total: Int

    private var fraction: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(current) / CGFloat(total)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.progressTrack)
                    .frame(height: 8)

                // Fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.primary)
                    .frame(width: geometry.size.width * min(fraction, 1.0), height: 8)
                    .animation(.easeInOut(duration: 0.3), value: fraction)
            }
        }
        .frame(height: 8)
    }
}

#Preview {
    ProgressBarView(current: 6, total: 10)
        .padding()
        .background(Color.black)
}
