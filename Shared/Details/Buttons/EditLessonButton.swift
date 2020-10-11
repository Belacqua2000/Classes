//
//  EditLessonButton.swift
//  Classes
//
//  Created by Nick Baughan on 10/10/2020.
//

import SwiftUI

struct EditLessonButton: View {
    @EnvironmentObject var viewStates: LessonsStateObject
    var lessons: [Lesson]
    var body: some View {
        Button(action: {
            guard !lessons.isEmpty else { return }
            viewStates.lessonToChange = lessons.first!
            #if os(iOS)
            viewStates.addLessonIsPresented = true
            #endif
        }, label: {
            Label("Edit Info", systemImage: "rectangle.and.pencil.and.ellipsis")
        })
        .disabled(lessons.count != 1)
        .help("Edit the lesson info")
    }
}
