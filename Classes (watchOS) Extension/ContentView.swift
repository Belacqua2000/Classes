//
//  ContentView.swift
//  Classes (watchOS) Extension
//
//  Created by Nick Baughan on 10/11/2020.
//

import SwiftUI

struct ContentView: View {
    @State private var bool: Bool = false
    @State private var text: String = ""
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
                  animation: .default)
    private var lessons: FetchedResults<Lesson>
    var testLessons: [Lesson] = []
    
    var body: some View {
        if !lessons.isEmpty {
            List {
                ForEach(lessons) { lesson in
                    VStack {
                        Label(lesson.title ?? "Untitled", systemImage: Lesson.lessonIcon(type: lesson.type))
                        Text(lesson.teacher ?? "No Teacher")
                    }
                }
            }.navigationTitle("All Lessons")
        } else {
            Text("No lessons.  Please add on iPhone and make sure iCloud is turned on.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let context = PersistenceController.preview.container.viewContext
    static var previews: some View {
        ContentView(testLessons: Lesson.sampleData(context: context))
    }
}
