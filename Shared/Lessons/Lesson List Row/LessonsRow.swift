//
//  LessonsRow.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI

struct LessonsRow: View {
    @EnvironmentObject var viewStates: LessonsListHelper
    @Binding var selection: Set<Lesson>
    
    @ObservedObject var lesson: Lesson
    var body: some View {
//        NavigationLink(
//            destination: DetailView(lesson: lesson).environmentObject(viewStates),
//            tag: Set<Lesson>([lesson]),
//            selection: $selection,
//            label: {LessonCell(lesson: lesson)})
        NavigationLink(
            destination: DetailView(lesson: lesson).environmentObject(viewStates),
            label: {
                LessonCell(lesson: lesson)
            })
//        #elseif os(macOS)
//        LessonCell(lesson: lesson)
//        #endif
    }
}

/*
struct LessonsRow_Previews: PreviewProvider {
    static var previews: some View {
        LessonsRow(lesson: <#Binding<Lesson>#>)
    }
}*/
