import Core
import SwiftUI

public struct App<Env: Core.Env>: SwiftUI.App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    public init() {}

    public var body: some Scene {
        WindowGroup {
            ContentView(envName: Env.envName)
        }
    }
}
