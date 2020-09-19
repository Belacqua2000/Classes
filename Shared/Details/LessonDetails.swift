//
//  LessonDetails.swift
//  Classes
//
//  Created by Nick Baughan on 18/09/2020.
//

import SwiftUI

struct LessonDetails: View {
    @ObservedObject var lesson: Lesson
    var body: some View {
        Text(lesson.title ?? "No Title")
            .font(.title)
            .bold()
            .fixedSize(horizontal: false, vertical: true)
        
        #if !os(macOS)
        Label(title: {
            Text(lesson.date ?? Date(), style: .date)
                .bold()
        }, icon: {
            Image(systemName: "calendar")
        })
        .font(.title2)
        .navigationTitle("\(lesson.type ?? "Class") Details")
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
        .padding(.bottom)
    }
}
