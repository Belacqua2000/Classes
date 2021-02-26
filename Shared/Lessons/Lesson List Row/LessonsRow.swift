//
//  LessonsRow.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI

struct LessonsRow: View {
    @EnvironmentObject var viewStates: LessonsListHelper
    
    @ObservedObject var lesson: Lesson
    var body: some View {
//        #if os(macOS)
//        NavigationLink(
//            destination: DetailView(lesson: lesson).environmentObject(viewStates),
//            tag: Set<Lesson>([lesson]),
//            selection: $viewStates.selection,
//            label: {LessonCell(lesson: lesson)})
//        #else
        NavigationLink(
            destination: DetailView(lesson: lesson).environmentObject(viewStates),
            label: {
                LessonCell(lesson: lesson)
            })
//        #endif
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
