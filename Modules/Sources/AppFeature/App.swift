import SwiftUI

public struct App<Env: AppFeature.Env>: SwiftUI.App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    public init() {}

    public var body: some Scene {
        WindowGroup {
            ContentView(envName: Env.envName)
        }
    }
}
