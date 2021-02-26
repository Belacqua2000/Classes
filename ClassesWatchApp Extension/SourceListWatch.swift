//
//  SourceListWatch.swift
//  ClassesWatchApp Extension
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct SourceListWatch: View {
    
    @State var selection: SourceListItem? = .init(sidebarType: .today)
    
    var body: some View {
        List {
            AllLessonsListItem(selection: $selection)
            SmartGroupsList(selection: $selection)
            LessonTypeList()
            TagList()
            #if targetEnvironment(simulator)
            AddDataButton()
            #endif
        }
        .navigationTitle("Classes")
    }
}

struct AddDataButton: View {
    @Environment(\.managedObjectContext) var viewContext
    var body: some View {
        Button("Add Sample Data", action: addData)
    }
    
    func addData() {
        let lesson1 = Lesson(context: viewContext)
        lesson1.id = UUID()
        lesson1.title = "Introduction to Physiology"
        lesson1.teacher = "Professor Smith"
        lesson1.date = Date(timeIntervalSinceReferenceDate: 621968400)
        lesson1.location = "Online"
        lesson1.watched = true
        lesson1.type = Lesson.LessonType.lecture.rawValue
        
        let ilo1 = ILO(context: viewContext)
        ilo1.id = UUID()
        ilo1.index = 0
        ilo1.title = "Define Homeostasis"
        let ilo2 = ILO(context: viewContext)
        ilo2.id = UUID()
        ilo2.index = 1
        ilo2.title = "Understand the importance of feedback loops"
        lesson1.addToIlo(ilo1)
        lesson1.addToIlo(ilo2)
        
        
        let lesson2 = Lesson(context: viewContext)
        lesson2.id = UUID()
        lesson2.title = "Methods for Effective Studying"
        lesson2.teacher = "Dr Jones"
        lesson2.date = Date(timeIntervalSinceReferenceDate: 622022400)
        lesson2.location = "Main Building"
        lesson2.watched = false
        lesson2.type = Lesson.LessonType.tutorial.rawValue
        
        let tag1 = Tag(context: viewContext)
        tag1.name = "Medicine"
        tag1.id = UUID()
        tag1.color = UIColor(Color.blue)
        tag1.addToLesson(lesson1)
        
        let tag2 = Tag(context: viewContext)
        tag2.id = UUID()
        tag2.name = "Week 2"
        tag2.color = UIColor(Color.red)
        tag2.addToLesson(lesson1)
        tag2.addToLesson(lesson2)
    }
}

struct SourceListWatch_Previews: PreviewProvider {
    static var previews: some View {
        SourceListWatch()
    }
}
