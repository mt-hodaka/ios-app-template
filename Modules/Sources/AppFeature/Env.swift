import Foundation

public class Env: ObservableObject {
    @Published var message: String

    public init(message: String) {
        self.message = message
    }
}
