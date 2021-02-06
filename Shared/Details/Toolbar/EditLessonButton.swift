//
//  EditLessonButton.swift
//  Classes
//
//  Created by Nick Baughan on 10/10/2020.
//

import SwiftUI

struct EditLessonButton: View {
    @ObservedObject var detailStates: DetailViewStates
    @ObservedObject var lesson: Lesson
    
    #if os(macOS)
    let buttonText = "Edit"
    #else
    let buttonText = "Edit Lesson"
    #endif
    
    var body: some View {
        
        Button(action: editLesson, label: {
            Label(buttonText, systemImage: "pencil")
        })
        .help("Edit the lesson info")
        .onReceive(NotificationCenter.default.publisher(for: .editLesson), perform: { _ in
            editLesson()
        })
        
    }
    
    private func editLesson() {
        detailStates.lessonToChange = lesson
        detailStates.editLessonShown = true
    }
}
