//
//  GowiApp.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import GowiAppModel

/**
 ## Gowi Application Entry Point
 
 Main SwiftUI App structure that configures the application's scene hierarchy, window management,
 and core dependencies. Implements the MSV (Model StateView View) architecture pattern with
 centralized state management through AppModel.
 
 ### Architecture Overview:
 - **Single AppModel Instance**: Shared across all scenes via `AppModel.shared`
 - **Multi-Window Support**: Uses `WindowGroup` with custom routing for window management
 - **Deep Linking**: Handles `gowi://` URLs for navigation between windows and states
 - **Command Integration**: Provides comprehensive menu bar with keyboard shortcuts
 - **Testing Support**: Detects `--uitesting-reset-state` for test environment setup
 
 ### Dependencies:
 - `AppModel.shared`: Centralized business logic and CoreData management
 - `AppDelegate`: AppKit integration for functionality not available in SwiftUI
 - `Main`: Root StateView that coordinates window content and routing
 - `Menubar`: Complete menu bar implementation with commands
 */
@main
struct GowiApp: App {
    /// Window group identifiers for multi-window scene management
    /// 
    /// Each case represents a distinct window type that can be created and managed
    /// independently with its own routing state and lifecycle.
    enum WindowGroupId: String {
        case Main
    }
    
    /// Initializes the application with command-line argument processing
    ///
    /// Handles special command-line flags for testing and development:
    /// - `--uitesting-reset-state`: Clears all UserDefaults to provide clean test environment
    init() {
         // Parse command-line arguments for testing support
         if CommandLine.arguments.contains("--uitesting-reset-state") {
             // Clear UserDefaults to ensure clean state for UI testing
             if let bundleID = Bundle.main.bundleIdentifier {
                 UserDefaults.standard.removePersistentDomain(forName: bundleID)
                 UserDefaults.standard.synchronize()
             }
             // Additional state reset could include: delete files, clear caches, reset keychain items
         }
     }
    

    /*
     ## Why Use AppModel.shared Instead of Just @StateObject?
     
     While @StateObject handles lifecycle management for SwiftUI views, AppModel.shared provides
     a consistent instance across the entire application, including areas where @StateObject
     doesn't work:
     
     1. **SwiftUI Command Builders**: Menu commands (like Menubar) can't access @StateObject
     2. **AppKit Integration**: AppDelegate and other AppKit code needs direct model access  
     3. **Multi-Window Consistency**: All windows share the same model instance
     4. **Testing**: Provides predictable instance for test injection via GOWI_TESTMODE
     
     The combination of @StateObject + AppModel.shared ensures both SwiftUI lifecycle management
     AND universal accessibility throughout the app.
     */

    /// The application's centralized model instance
    ///
    /// Uses AppModel.shared to ensure consistent access across SwiftUI views, AppKit components,
    /// and command builders. The @StateObject wrapper provides proper SwiftUI lifecycle management.
    @StateObject var appModel = AppModel.shared

    /// AppKit delegate for functionality not available in SwiftUI
    ///
    /// Provides access to NSApplication delegate methods like applicationShouldTerminate
    /// for handling unsaved changes on app exit.
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        // Main window group with deep linking and routing support
        WindowGroup(id: WindowGroupId.Main.rawValue, for: Main.WindowGroupRoutingOpt.self) { $route in
            // For detailed routing documentation, see Main#WindowGroupRouteView.swift
            Main(with: appModel.systemRootItem, route: $route)
                .environmentObject(appModel)
                .environment(\.managedObjectContext, appModel.viewContext)
                // Handle external URL events (gowi:// scheme) - prefers Main URLs, allows fallback to any
                .handlesExternalEvents(preferring: [Main.UrlRoot.absoluteString], allowing: ["*"])
                .onAppear {
                    // Late-bind appModel to delegate since @NSApplicationDelegateAdaptor
                    // doesn't support constructor injection
                    appDelegate.appModel = appModel
                }
        }
        // Window group level URL handling - matches gowi:// URLs to this window group
        .handlesExternalEvents(matching: [Main.UrlRoot.absoluteString])
        .commands {
            // Application menu commands with model integration
            Menubar(appModel: appModel)
            // Standard SwiftUI text editing commands (Cut, Copy, Paste, etc.)
            TextEditingCommands()
            // Standard sidebar show/hide commands
            SidebarCommands()
            // Standard toolbar show/hide commands  
            ToolbarCommands()
        }
    }
}
