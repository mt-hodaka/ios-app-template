import FirebaseAnalytics
import SwiftUI
import UIComponents

public struct ContentView: View {
    @State private var envName: String

    public init(envName: String) {
        self.envName = envName
    }

    public var body: some View {
        VStack(spacing: 10.0) {
            Label {
                Text(L10n.Sample.envNameTitle(envName))
                    .font(.headline)
            } icon: {
                Asset.Images.sample.swiftUIImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 18.0)
            }
            .foregroundColor(Asset.Colors.sample.swiftUIColor)

            Button(L10n.Sample.textLogEventButton) {
                Analytics.logEvent("Test log event", parameters: nil)
            }

            Button(L10n.Sample.crashButton) {
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
