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
        /*.onDrag({
            return NSItemProvider(object: lesson.id!.uuidString as NSString)
        })*/
        #elseif os(macOS)
        LessonCell(lesson: lesson)
            .onDrag({
                return NSItemProvider(object: lesson.id!.uuidString as NSString)
            })
        #endif
    }
}

/*
struct LessonsRow_Previews: PreviewProvider {
    static var previews: some View {
        LessonsRow(lesson: <#Binding<Lesson>#>)
    }
}*/
