//
//  LessonContextMenu.swift
//  Classes
//
//  Created by Nick Baughan on 06/02/2021.
//

import SwiftUI

struct LessonContextMenu: View {
    @ObservedObject var lesson: Lesson
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var lessonsListHelper: LessonsListHelper
    
    var body: some View {
        Button(action: {lessonsListHelper.editLesson(lesson)}, label: {
            Label("Edit", systemImage: "square.and.pencil")
        }).keyboardShortcut("E", modifiers: .command)
        
        Button(action: {lessonsListHelper.duplicateLesson(lesson)}, label: {
            Label("Duplicate Lesson", systemImage: "plus.square.on.square")
        }).keyboardShortcut("D", modifiers: .command)
        
        Divider()
        
        Button(action: {lessonsListHelper.toggleWatched(lessons: [lesson])}, label: {
            !lesson.watched ? Label("Mark Complete", systemImage: "checkmark.circle")
                : Label("Mark Incomplete", systemImage: "checkmark.circle")
        }).keyboardShortcut("Y", modifiers: .command)
        
        Button(action: {lessonsListHelper.markOutcomesWritten(lesson)}, label: {
            Label("Mark Outcomes as Written", systemImage: "checkmark.circle")
        })
        
        Button(action: {lessonsListHelper.markOutcomesUnwritten(lesson)}, label: {
            Label("Mark outcomes as Unwritten", systemImage: "xmark.circle")
        })
        
        Divider()
        
        #if os(iOS)
        Menu(content: {
            Button(action: {lessonsListHelper.showShareSheet(lesson)}, label: {
                Label("Share", systemImage: "square.and.arrow.up")
            })
            
            Button(action: {lessonsListHelper.showExporter(lesson: lesson)}, label: {
                Label("Save to Files", systemImage: "folder")
            })
            
        }, label: {
            Label("Export", systemImage: "square.and.arrow.up")
        })
        
        #else
        
        Button(action: {lessonsListHelper.showExporter(lesson: lesson)}, label: {
            Label("Export", systemImage: "square.and.arrow.up")
        })
        
        #endif
        
        Button(action: {
            lessonsListHelper.selection = [lesson]
            lessonsListHelper.deleteAlertShown = true
        }, label: {
            Label("Delete", systemImage: "trash")
                .foregroundColor(.red)
        })
    }
    
}
