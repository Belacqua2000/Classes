//
//  BottomToolbar.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 01/10/2020.
//

import SwiftUI

struct BottomToolbar: View {
    @Environment(\.editMode) private var editMode
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var selection: Set<Lesson>
    
    var lessonCount: Int = 0
    
    var body: some View {
        EditButton()
        
        Spacer()
        
        Button(action: { NotificationCenter.default.post(name: .scrollToNow, object: nil) }, label: {
            Label("Scroll to Next", systemImage: "calendar.badge.clock")
        })
        .help("Scroll to the next lesson after now.")
        .disabled(lessonCount == 0)
        
        Spacer()
        
        if editMode?.wrappedValue.isEditing == true {
            Button(action: {/*deleteLessonAlert(lessons: Array(selection))*/}, label: {
                Label("Delete", systemImage: "trash")
            })
            Button(action: toggleWatched, label: {
                Label("Toggle Watched", systemImage: "checkmark.circle.fill")
            })
        }
    }
    
    private func toggleWatched() {
        for lesson in selection {
            lesson.toggleWatched(context: viewContext)
        }
    }
}

struct BottomToolbar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Lorum Ipsum")
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        BottomToolbar(selection: .constant(Set<Lesson>()))
                    }
            }
        }
    }
}
