//
//  AppCommands.swift
//  Classes
//
//  Created by Nick Baughan on 01/10/2020.
//

import SwiftUI
import NotificationCenter

struct AppCommands: Commands {
    let nc = NotificationCenter.default
    var body: some Commands {
        
        CommandGroup(after: .newItem) {
            Button("New Lesson", action: newLesson)
                .keyboardShortcut("n", modifiers: [.command, .shift])
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
}

