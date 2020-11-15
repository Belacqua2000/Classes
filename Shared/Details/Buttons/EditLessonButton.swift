//
//  EditLessonButton.swift
//  Classes
//
//  Created by Nick Baughan on 10/10/2020.
//

import SwiftUI

struct EditLessonButton: View {
    @ObservedObject var detailStates: DetailViewStates
    var lessons: [Lesson]
    var body: some View {
        Button(action: editLesson, label: {
            Label("Edit Info", systemImage: "rectangle.and.pencil.and.ellipsis")
        })
        .disabled(lessons.count != 1)
        .help("Edit the lesson info")
        .onReceive(NotificationCenter.default.publisher(for: .editLesson), perform: { _ in
            editLesson()
        })
    }
    
    private func editLesson() {
        guard !lessons.isEmpty else { return }
        detailStates.lessonToChange = lessons.first!
        detailStates.editLessonShown = true
    }
}
