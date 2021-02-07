//
//  LessonDetails.swift
//  Classes
//
//  Created by Nick Baughan on 18/09/2020.
//

import SwiftUI

struct LessonDetails: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var lesson: Lesson
    
    var completedLabel: some View {
        lesson.watched ? Label("Completed", systemImage: "checkmark.circle.fill") : Label("Not Completed", systemImage: "xmark.circle")
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(lesson.title ?? "No Title")
                    .font(.title)
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
                #if !os(macOS)
                Label(title: {
                    Text("\(lesson.date ?? Date(), style: .date), \(lesson.date ?? Date(), style: .time)")
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                }, icon: {
                    Image(systemName: "calendar")
                })
                .font(.title2)
                .navigationTitle("\(lesson.type ?? "Lesson") Details")
                .navigationBarTitleDisplayMode(.inline)
                #else
                Label(title: {
                    Text("\(lesson.date ?? Date(), style: .date), \(lesson.date ?? Date(), style: .time)")
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                }, icon: {
                    Image(systemName: "calendar")
                })
                .font(.title2)
                #endif
                
                if let teacher = lesson.teacher, !teacher.isEmpty {
                    Label(title: {
                        Text(teacher)
                            .fixedSize(horizontal: false, vertical: true)
                    }, icon: {
                        Image(systemName: "graduationcap")
                    })
                    .font(.title2)
                }
                
                if let location = lesson.location, !location.isEmpty {
                    Label(title: {
                        Text(location)
                    }, icon: {
                        Image(systemName: "mappin")
                    })
                    .font(.title2)
                }
                
                #if os(iOS)
                Button(action: {lesson.toggleWatched(context: viewContext)}, label: { completedLabel })
                .font(.title2)
                #else
                completedLabel
                #endif
            }
            Spacer()
        }.modifier(DetailBlock())
    }
}
