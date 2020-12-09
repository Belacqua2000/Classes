//
//  LessonsRow.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI

struct LessonsRow: View {
    @EnvironmentObject var viewStates: LessonsStateObject
    @Binding var selection: Set<Lesson>
    
    @ObservedObject var lesson: Lesson
    var lessonSet: Set<Lesson> {
        var set = Set<Lesson>()
        set.insert(lesson)
        return set
    }
    var body: some View {
//        #if os(iOS)
        
        NavigationLink(destination: DetailView(lesson: lesson).environmentObject(viewStates), label: {
            LessonCell(lesson: lesson)
        })
        /*.onDrag({
            return NSItemProvider(object: lesson.id!.uuidString as NSString)
        })*/
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
