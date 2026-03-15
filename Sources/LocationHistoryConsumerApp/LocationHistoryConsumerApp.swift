#if canImport(SwiftUI)
import SwiftUI

@main
struct LocationHistoryConsumerApp: App {
    var body: some Scene {
        WindowGroup {
            AppShellRootView()
        }
    }
}
#else
import Foundation

@main
enum LocationHistoryConsumerApp {
    static func main() {
        print("LocationHistoryConsumerApp requires SwiftUI on Apple platforms.")
    }
}
#endif
