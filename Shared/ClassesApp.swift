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
    
    @ObservedObject var appViewState = AppViewState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewState)
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
            /*SettingsView(viewIsShown: .constant(true))
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)*/
        }
        #endif
    }
}
