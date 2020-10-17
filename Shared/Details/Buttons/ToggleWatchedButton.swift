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
    var lessons: [Lesson]
    var body: some View {
        Button(action: toggleWatched, label: {
            if lessons.count == 1 {
                !(lessons.first?.watched ?? false) ?
                Label("Mark as Watched", systemImage: "checkmark.circle") : Label("Mark as Unwatched", systemImage: "checkmark.circle.fill")
            } else {
                Label("Toggle Watched", systemImage: "checkmark.circle")
            }
        })
        .disabled(lessons.isEmpty)
        .help("Toggle Watched")
        .onReceive(nc.publisher(for: .toggleWatched), perform: { _ in
            toggleWatched()
        })
    }
    
    func toggleWatched() {
        withAnimation {
            for lesson in lessons {
                lesson.toggleWatched(context: viewContext)
            }
        }
    }
}
