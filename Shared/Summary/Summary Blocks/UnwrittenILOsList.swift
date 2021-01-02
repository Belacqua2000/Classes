//
//  UnwrittenILOsList.swift
//  Classes
//
//  Created by Nick Baughan on 06/11/2020.
//

import SwiftUI

struct UnwrittenNotesList: View {
    var ilos: [ILO]
    var previousILOs: Int
    var writtenILOs: Int
    var lessonsWithOverdueILOs: [Lesson]
    var overdueILOsCount: Int
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Label("Notes to Write", systemImage: "doc.append")
                    .font(.headline)
                Text("You have written \(writtenILOs) learning outcomes out of \(previousILOs):")
                    .font(.subheadline)
                if ilos.count > 0 && previousILOs > 0 {
                    ProgressView(value: Double(writtenILOs)/Double(previousILOs))
                }
                Text("You have \(overdueILOsCount) learning outcomes to write up:")
                    .font(.subheadline)
                
                ForEach(lessonsWithOverdueILOs) { lesson in
                    let lesson = lesson as Lesson
                    #if os(iOS)
                    NavigationLink(
                        destination: DetailView(lesson: lesson).environmentObject(LessonsStateObject()),
                        label: {
                            Label(lesson.title ?? "Untitled", systemImage: Lesson.lessonIcon(type: lesson.type))
                                .font(.headline)
                        })
                    #else
                    Label(lesson.title ?? "Untitled", systemImage: Lesson.lessonIcon(type: lesson.type))
                        .font(.headline)
                    #endif
                    ForEach(lesson.overDueILOs()) { ilo in
                        Text("\(ilo.index + 1). \(ilo.title ?? "Untitled")")
                    }
                }
            }
            Spacer()
        }
        .modifier(DetailBlock())
    }
}
