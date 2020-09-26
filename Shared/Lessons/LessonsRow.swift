//
//  LessonsRow.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI

struct LessonsRow: View {
    var lesson: Lesson
    var body: some View {
        #if os(iOS)
        NavigationLink(destination: DetailView(lesson: lesson), label: {
            LessonCell(lesson: lesson)
        })
        #elseif os(macOS)
        LessonCell(lesson: lesson)
        #endif
    }
}

/*
struct LessonsRow_Previews: PreviewProvider {
    static var previews: some View {
        LessonsRow(lesson: <#Binding<Lesson>#>)
    }
}*/
