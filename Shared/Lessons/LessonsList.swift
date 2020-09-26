//
//  LessonsList.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI

struct LessonsList: View {
    
    @State private var addLessonSheetPresented = false
    @Binding var selectedLesson: Set<Lesson>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
        animation: .default)
    private var lessons: FetchedResults<Lesson>
    
    var body: some View {
        List(selection: $selectedLesson) {
                ForEach(lessons) { lesson in
                    //NavigationLink(destination: DetailView(lesson: lesson)) {
                    LessonCell(lesson: lesson).tag(lesson)
                    //}
                }
            }
            .toolbar {
                Button(action: addLesson, label: {
                    Label("Add Lesson", systemImage: "plus")
                })
                .help("Add a New Lesson")
            }
    }
    
    func addLesson() {
        addLessonSheetPresented = true
    }
    
}

struct LessonsList_Previews: PreviewProvider {
    static var previews: some View {
        LessonsList(selectedLesson: .constant(Set<Lesson>()))
    }
}
