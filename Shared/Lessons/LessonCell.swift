//
//  LessonCell.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct LessonCell: View {
    @ObservedObject var lesson: Lesson
    var tags: [Tag] {
        return lesson.tag?.allObjects as? [Tag] ?? []
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label(
                    title: { VStack(alignment: .leading) {
                        Text(lesson.title ?? "Untitled")
                            .font(.headline)
                        Text("\(lesson.date ?? Date(), style: .date) \(lesson.date ?? Date(), style: .time)")
                            .font(.subheadline)
                        Text(lesson.teacher ?? "No Teacher")
                            .font(.footnote)
                    } },
                    icon: {
                        Image(systemName: Lesson.lessonIcon(type: lesson.type))
                            .font(.headline)
                    }
                )
                Spacer()
                Text(lesson.location ?? "No Location")
                if lesson.watched {
                    Image(systemName: "checkmark.circle.fill")
                        .renderingMode(.original)
                }
            }
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
/*
 struct LessonCell_Previews: PreviewProvider {
 static var previews: some View {
 LessonCell(lesson: Lesson(context: <#T##NSManagedObjectContext#>))
 .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
 .frame(width: 200)
 }
 }*/
