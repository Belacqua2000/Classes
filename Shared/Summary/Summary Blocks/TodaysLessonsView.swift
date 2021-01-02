//
//  TodaysLessonsView.swift
//  Classes (macOS)
//
//  Created by Nick Baughan on 06/11/2020.
//

import SwiftUI

struct TodaysLessonsView: View {
    @Binding var detailShown: Bool
    var todaysLessons: [Lesson]
    var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Label("Today", systemImage: "calendar")
                        .font(.headline)
                    Text("You have \(todaysLessons.count) lessons today:")
                        .font(.subheadline)
                    ForEach(todaysLessons) { lesson in
                        let lesson = lesson as Lesson
                        #if !os(macOS)
                        VStack(alignment: .leading) {
                            Text("\(lesson.date ?? Date(), style: .time): ")
                                .font(.headline)
                                .underline()
                        }
                        NavigationLink(
                            destination: DetailView(lesson: lesson).environmentObject(LessonsStateObject()),
                            label: {
                                Label(
                                    title: {
                                        Text(lesson.title ?? "No Title")
                                    },
                                    icon: {
                                        Image(systemName: Lesson.lessonIcon(type: lesson.type!))
                                    })
                            })
                        #else
                        VStack(alignment: .leading) {
                            Text("\(lesson.date ?? Date(), style: .time): ")
                                .font(.headline)
                                .underline()
                            Label(
                                title: {
                                    Text(lesson.title ?? "No Title")
                                },
                                icon: {
                                    Image(systemName: Lesson.lessonIcon(type: lesson.type!))
                                })
                        }
                        #endif
                    }
                }
                Spacer()
            }.modifier(DetailBlock())
    }
}
