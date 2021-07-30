import FirebaseAnalytics
import SwiftUI

public struct ContentView: View {
    @EnvironmentObject var env: Env

    public init() {
    }

    public var body: some View {
        VStack(spacing: 10.0) {
            Text(env.message)
            Button("Log event") {
                Analytics.logEvent("Test log event", parameters: nil)
            }
            Button("Crash") {
                fatalError()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Env(message: "Preview App!"))
    }
}
