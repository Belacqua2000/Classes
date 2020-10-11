//
//  AppCommands.swift
//  Classes
//
//  Created by Nick Baughan on 01/10/2020.
//

import SwiftUI
import NotificationCenter
import UniformTypeIdentifiers

struct AppCommands: Commands {
    let nc = NotificationCenter.default
    @Environment(\.openURL) var openURL
    
    var body: some Commands {
        
        CommandGroup(after: .newItem) {
            Button("New Lesson", action: newLesson)
                .keyboardShortcut("n", modifiers: [.command, .shift])
            Divider()
            Button("Import...", action: importFiles)
        }
        
        CommandMenu("Lesson") {
            Button("Toggle Watched", action: toggleWatched)
                .keyboardShortcut("Y", modifiers: .command)
            Button("Edit Tags", action: {})
                .keyboardShortcut("T", modifiers: .command)
            Divider()
            Button("Add Learning Outcome", action: {})
                .keyboardShortcut("L", modifiers: .command)
            Button("Add Resource", action: addResource)
                .keyboardShortcut("R", modifiers: .command)
        }
    
        CommandGroup(replacing: .help) {
            Button("Launch Website", action: {
                openURL.callAsFunction(URL(string: "https://nickbaughanapps.wordpress.com")!)
            })
            .keyboardShortcut("?", modifiers: [.command, .option])
        }
        
        CommandGroup(after: .sidebar) {
            Divider()
            Button("Summary", action: showSummary)
                .keyboardShortcut("1", modifiers: .command)
            Button("All Lessons", action: showAll)
                .keyboardShortcut("2", modifiers: .command)
            Button("Learning Outcomes", action: showILO)
                .keyboardShortcut("3", modifiers: .command)
        }
    }
    
    func showSummary() {
        nc.post(Notification(name: .showSummary))
    }
    
    func showAll() {
        nc.post(Notification(name: .showAll))
    }
    
    func showILO() {
        nc.post(Notification(name: .showILOs))
    }
    
    
    func newLesson() {
        nc.post(Notification(name: .newLesson))
    }
    
    func importFiles() {
        nc.post(Notification(name: .importLessons))
    }
    
    
    func addResource() {
        nc.post(Notification(name: .addResource))
    }
    
    func toggleWatched() {
        nc.post(Notification(name: .toggleWatched))
    }
}

