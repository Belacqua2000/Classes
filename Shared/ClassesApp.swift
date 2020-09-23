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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            SidebarCommands()
            CommandGroup(after: .newItem, addition: {
                Button("New Lesson", action: {})
                .keyboardShortcut(KeyboardShortcut("n", modifiers: [.command, .shift]))
            })
        }
        #if os(macOS)
        Settings {
            SettingsView(viewIsShown: .constant(false))
        }
        #endif
    }
}
