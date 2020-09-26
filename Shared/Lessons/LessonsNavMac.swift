//
//  Lessons.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI

struct LessonsNavMac: View {
    @State private var selectedLesson = Set<Lesson>()
    @Binding var filter: LessonsFilter
    
    var body: some View {
        GeometryReader { gr in
            HSplitView {
                //LessonsList(selectedLesson: $selectedLesson)
                LessonsListContent(selection: $selectedLesson, filter: $filter)
                    .frame(idealWidth: gr.size.width / 2, maxWidth: .infinity, maxHeight: .infinity)
                if !selectedLesson.isEmpty {
                    DetailView(lesson: selectedLesson.first!)
                        .frame(idealWidth: gr.size.width / 2, maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Select a lesson")
                        .frame(idealWidth: gr.size.width / 2, maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

struct LessonsNavMac_Previews: PreviewProvider {
    static var previews: some View {
        LessonsNavMac(filter: .constant(LessonsFilter(filterType: .all, lessonType: nil, tag: nil)))
    }
}
