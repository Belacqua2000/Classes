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
    
    var relativeText: Text? {
        let calendar = Calendar.current
        if calendar.isDateInToday(lesson.date ?? Date(timeIntervalSince1970: 0)) && lesson.date ?? Date(timeIntervalSince1970: 0) > Date() {
            return Text("— in \(lesson.date!, style: .relative)").foregroundColor(.red)
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label(
                    title: { VStack(alignment: .leading) {
                        Text(lesson.title ?? "Untitled")
                            .font(.headline)
                        Text("\(itemFormatter.string(from: lesson.date ?? Date())) \(relativeText ?? Text(""))")
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
                        .foregroundColor(.accentColor)
                        //.renderingMode(.original)
                }
            }
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
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
