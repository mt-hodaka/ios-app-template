import FirebaseAnalytics
import SwiftUI

public struct ContentView: View {
    @State private var envName: String

    public init(envName: String) {
        self.envName = envName
    }

    public var body: some View {
        VStack(spacing: 10.0) {
            Text("\(envName) App!")
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
        ContentView(envName: "Preview")
    }
}
