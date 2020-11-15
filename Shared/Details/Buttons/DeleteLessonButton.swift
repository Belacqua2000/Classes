//
//  DeleteLessonButton.swift
//  Classes
//
//  Created by Nick Baughan on 10/10/2020.
//

import SwiftUI

struct DeleteLessonButton: View {
    @ObservedObject var viewStates: DetailViewStates
    #if os(iOS)
    var lesson: Lesson
    #endif
    var body: some View {
        Button(action: {
            #if os(iOS)
            viewStates.lessonToChange = lesson
            
            #endif
            viewStates.deleteAlertShown = true
        }, label: {
            Label("Delete Lesson", systemImage: "trash")
        })
        .help("Delete the lesson")
    }
}

struct DeleteLessonButton_Previews: PreviewProvider {
    static var previews: some View {
        #if os(macOS)
        DeleteLessonButton(viewStates: DetailViewStates())
        #endif
    }
}
