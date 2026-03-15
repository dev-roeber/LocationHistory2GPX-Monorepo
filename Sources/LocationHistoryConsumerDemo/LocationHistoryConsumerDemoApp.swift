#if canImport(SwiftUI)
import SwiftUI

@main
struct LocationHistoryConsumerDemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
#else
import Foundation

@main
enum LocationHistoryConsumerDemoApp {
    static func main() {
        print("LocationHistoryConsumerDemo requires SwiftUI on Apple platforms.")
    }
}
#endif
