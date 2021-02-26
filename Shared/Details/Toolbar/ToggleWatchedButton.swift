//
//  ToggleWatchedButton.swift
//  Classes
//
//  Created by Nick Baughan on 10/10/2020.
//

import SwiftUI

struct ToggleWatchedButton: View {
    let nc = NotificationCenter.default
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var lesson: Lesson
    
    var lessonLabel: some View {
        #if os(macOS)
        return !lesson.watched ?
            Label("Mark Completed", systemImage: "checkmark.circle") : Label("Mark Uncompleted", systemImage: "checkmark.circle.fill")
        #else
        return !lesson.watched ?
            Label("Not Completed", systemImage: "xmark.circle") : Label("Completed", systemImage: "checkmark.circle.fill")
        #endif
    }
    
    var body: some View {
        Button(action: toggleWatched, label: {lessonLabel})
            .help(lesson.watched ? "Mark lesson as uncompleted" : "Mark lesson as completed")
            .onReceive(nc.publisher(for: .toggleWatched), perform: { _ in
                toggleWatched()
            })
    }
    
    private func toggleWatched() {
        withAnimation {
            lesson.toggleWatched(context: viewContext)
        }
    }
}
