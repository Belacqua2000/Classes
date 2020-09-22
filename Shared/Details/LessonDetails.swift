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
    var body: some View {
        VStack(alignment: .leading) {
            Text(lesson.title ?? "No Title")
                .font(.title)
                .bold()
                .fixedSize(horizontal: false, vertical: true)
            #if !os(macOS)
            Label(title: {
                Text("\(lesson.date ?? Date(), style: .date), \(lesson.date ?? Date(), style: .time)")
                    .bold()
            }, icon: {
                Image(systemName: "calendar")
            })
            .font(.title2)
            .navigationTitle("\(lesson.type ?? "Lesson") Details")
            .navigationBarTitleDisplayMode(.inline)
            #else
            Label(title: {
                Text(lesson.date ?? Date(), style: .date)
                    .bold()
            }, icon: {
                Image(systemName: "calendar")
            })
            .font(.title2)
            #endif
            
            Label(title: {
                Text(lesson.teacher ?? "")
            }, icon: {
                Image(systemName: "graduationcap")
            })
            .font(.title2)
            
            Label(title: {
                Text(lesson.location ?? "No Location")
                    .italic()
            }, icon: {
                Image(systemName: "mappin")
            })
            .font(.title3)
            
            Button(action: {lesson.toggleWatched(context: viewContext)}, label: {
                lesson.watched ? Label("Watched", systemImage: "checkmark.circle.fill") : Label("Unwatched", systemImage: "checkmark.circle")
            })
            .font(.title3)
            .padding(.bottom)
        }
    }
}
