import SwiftUI

/// The main entry point for the ThethaFeed iOS application.
///
/// This app uses a dark color scheme throughout and presents the
/// QuestionnaireScreen as the root view, matching the React Native
/// app's single-screen navigation approach with state-driven UI.
///
/// Bundle identifier: app.rork.thethafeedversiononewithoutanimationv1
@main
struct ThethaFeedApp: App {
    var body: some Scene {
        WindowGroup {
            //.preferredColorScheme(.dark)
             QuestionnaireScreen()
                 .preferredColorScheme(.dark)
        }
    }
}
