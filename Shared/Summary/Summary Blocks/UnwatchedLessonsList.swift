//
//  UnwatchedLessonsList.swift
//  Classes
//
//  Created by Nick Baughan on 06/11/2020.
//

import SwiftUI

struct UnwatchedLessonsList: View {
    var overdueLessons: [Lesson]
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Label("Unwatched Lessons", systemImage: "tv")
                    .font(.headline)
                Text("You have \(overdueLessons.count) Lessons to watch:")
                    .font(.subheadline)
                ForEach(overdueLessons) { lesson in
                    let lesson = lesson as Lesson
                    #if os(iOS)
                    NavigationLink(
                        destination: DetailView(lesson: lesson).environmentObject(LessonsStateObject()),
                        label: {
                            Label(lesson.title ?? "No Title", systemImage: Lesson.lessonIcon(type: lesson.type!))
                        })
                    #else
                    Label(lesson.title ?? "No Title", systemImage: Lesson.lessonIcon(type: lesson.type!))
                    #endif
                }
            }
            Spacer()
        }.modifier(DetailBlock())
    }
}
