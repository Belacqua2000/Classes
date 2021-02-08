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
        !lesson.watched ?
            Label("Not Completed", systemImage: "xmark.circle") : Label("Completed", systemImage: "checkmark.circle.fill")
    }
    
    var body: some View {
        Button(action: toggleWatched, label: {lessonLabel})
            .help("Toggle Watched")
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
