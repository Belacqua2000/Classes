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
    @ObservedObject var appViewState: AppViewState
    
    var body: some Commands {
        
        CommandGroup(after: .newItem) {
            Button("New Lesson", action: newLesson)
                .keyboardShortcut("n", modifiers: [.command, .shift])
        }
        
        CommandMenu("Lesson") {
            Button("Edit Lesson Details", action: {postNotification(.init(name: .editLesson))})
                .keyboardShortcut("E", modifiers: .command)
                .help("Edit the lessons")
                .disabled(!appViewState.detailViewShowing)
            Button("Toggle Watched", action: toggleWatched)
                .keyboardShortcut("Y", modifiers: .command)
            Button("Edit Tags", action: allocateTagView)
                .keyboardShortcut("T", modifiers: .command)
                .disabled(!appViewState.detailViewShowing)
            Divider()
            Button("Add Learning Outcome", action: addILO)
                .keyboardShortcut("L", modifiers: .command)
                .disabled(!appViewState.detailViewShowing)
            Button("Add Resource", action: addResource)
                .keyboardShortcut("R", modifiers: .command)
                .disabled(!appViewState.detailViewShowing)
        }
    
        CommandGroup(replacing: .help) {
            Button("What's New", action: whatsNew)
            Button("Launch Website", action: {
                openURL.callAsFunction(URL(string: "https://nickbaughanapps.wordpress.com")!)
            })
            .keyboardShortcut("?", modifiers: [.command, .option])
        }
        
        CommandGroup(after: .sidebar) {
            Divider()
            Button("Scroll List to Now", action: scrollToNow)
                .keyboardShortcut("s")
            Divider()
            Button("Summary", action: showSummary)
                .keyboardShortcut("1", modifiers: .command)
                .disabled(appViewState.currentTab == .summary)
            Button("All Lessons", action: showAll)
                .keyboardShortcut("2", modifiers: .command)
                .disabled(appViewState.currentTab == .all)
            Button("Learning Outcomes", action: showILO)
                .keyboardShortcut("3", modifiers: .command)
                .disabled(appViewState.currentTab == .ilo)
            Divider()
        }
    }
    
    func postNotification(_ notification: Notification) {
        nc.post(notification)
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
    
    func scrollToNow() {
        nc.post(Notification(name: .scrollToNow))
    }
    
    
    func newLesson() {
        nc.post(Notification(name: .newLesson))
    }
    
    func importFiles() {
        nc.post(Notification(name: .importLessons))
    }
    
    
    func addILO() {
        nc.post(Notification(name: .addILO))
    }
    
    func addResource() {
        nc.post(Notification(name: .addResource))
    }
    
    func toggleWatched() {
        nc.post(Notification(name: .toggleWatched))
    }
    
    func allocateTagView() {
        nc.post(Notification(name: .tagAllocateViewShown))
    }
    
    
    func whatsNew() {
        nc.post(Notification(name: .showWhatsNew))
    }
}

