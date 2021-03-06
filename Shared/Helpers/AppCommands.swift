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
        
        CommandGroup(replacing: .importExport) {
            Button("Import Lessons", action: {postNotification(.init(name: .importLessons))})
            Button("Export Lessons in Current View", action: {postNotification(.init(name: .exportCurrentView))})
            Button("Export All Lessons", action: {postNotification(.init(name: .exportAll))})
        }
        
        CommandMenu("Lesson") {
            Button("Edit Lesson", action: {postNotification(.init(name: .editLesson))})
                .keyboardShortcut("E", modifiers: .command)
                .help("Edit the lessons")
//                .disabled(!appViewState.detailViewShowing)
            Button("Edit Tags", action: allocateTagView)
                .keyboardShortcut("T", modifiers: .command)
//                .disabled(!appViewState.detailViewShowing)
            Divider()
            Button("Toggle Completed", action: toggleWatched)
                .keyboardShortcut("Y", modifiers: .command)
            Button("Mark Learning Outcomes as Achieved", action: {postNotification(.init(name: .markILOsWritten))})
                .keyboardShortcut("D", modifiers: .command)
            Button("Mark Learning Outcomes as Unachieved", action: {postNotification(.init(name: .markILOsUnwritten))})
                .keyboardShortcut("U", modifiers: .command)
            Divider()
            Button("Add Learning Outcome", action: addILO)
                .keyboardShortcut("L", modifiers: .command)
//                .disabled(!appViewState.detailViewShowing)
            Button("Add Link", action: addResource)
                .keyboardShortcut("R", modifiers: .command)
//                .disabled(!appViewState.detailViewShowing)
        }
    
        CommandGroup(replacing: .help) {
            Button("Classes Help", action: {
                openURL.callAsFunction(URL(string: "https://nickbaughanapps.wordpress.com/classes/help")!)
            })
            .keyboardShortcut("?", modifiers: [.command, .option])
            Divider()
            Button("What's New", action: whatsNew)
            Button("Tutorial", action: {postNotification(.init(name: .onboarding))})
            Button("Launch Website", action: {
                openURL.callAsFunction(URL(string: "https://nickbaughanapps.wordpress.com")!)
            })
        }
        
        CommandGroup(after: .sidebar) {
            Divider()
            Menu("Scroll to...") {
                Button("Scroll to Oldest", action: {postNotification(.init(name: .scrollToOldest))})
                Button("Scroll to Now", action: scrollToNow)
                    .keyboardShortcut("s")
                Button("Scroll to Newest", action: {postNotification(.init(name: .scrollToNewest))})
            }
            Button("Filter Lessons", action: {postNotification(.init(name: .showFilterView))})
                .keyboardShortcut("f")
            Button("Show Outcome Randomiser", action: {postNotification(.init(name: .showILORandomiser))})
                .keyboardShortcut("l")
            Divider()
        }
    }
    
    private func postNotification(_ notification: Notification) {
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

