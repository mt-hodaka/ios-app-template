import AppFeature
import SwiftUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Env())
        }
    }
}
