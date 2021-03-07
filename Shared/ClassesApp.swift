//
//  ClassesApp.swift
//  Shared
//
//  Created by Nick Baughan on 05/09/2020.
//

import SwiftUI

@main
struct ClassesApp: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject var appViewState = AppViewState()

    var body: some Scene {
        WindowGroup {
            
//            ContentView()
//                .environmentObject(appViewState)
            NewNavigation()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            AppCommands(appViewState: appViewState)
            SidebarCommands()
            ToolbarCommands()
        }
        
        #if os(macOS)
        Settings {
            SettingsViewMac()
        }
        #endif
    }
}
