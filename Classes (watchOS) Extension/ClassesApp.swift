//
//  ClassesApp.swift
//  Classes (watchOS) Extension
//
//  Created by Nick Baughan on 10/11/2020.
//

import SwiftUI

@main
struct ClassesApp: App {
    let persistenceController = PersistenceController.shared
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
