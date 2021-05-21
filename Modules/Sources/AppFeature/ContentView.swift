import SwiftUI

public struct ContentView: View {
    @EnvironmentObject var env: Env

    public init() {
    }

    public var body: some View {
        Text(env.message)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Env(message: "Preview App!"))
    }
}
