//
//  ClassesApp.swift
//  ClassesWatchApp Extension
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

@main
struct ClassesApp: App {
    let persistenceController = PersistenceController.shared
    @SceneBuilder var body: some Scene {
        WindowGroup {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
