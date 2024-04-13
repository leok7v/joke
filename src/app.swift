import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        #if os(macOS)
        // Using Window for macOS
        Window("YLIP", id: "mainWindow") {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .help) {}
            CommandGroup(replacing: .systemServices) {}
        }
        #else
        // Using WindowGroup for iOS and other platforms
        WindowGroup {
            ContentView()
        }
        #endif
    }
}



