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
    
    let calendar = Calendar.current
    
    var dateText: String {
        return DateFormatter.localizedString(from: lesson.date ?? Date(), dateStyle: .short, timeStyle: .short)
    }
    
    var relativeText: Text {
        return Text("— in \(lesson.date!, style: .relative)").foregroundColor(.red)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label(
                    title: { VStack(alignment: .leading) {
                        Text(lesson.title ?? "Untitled")
                            .font(.headline)
                        
                        if calendar.isDateInToday(lesson.date ?? Date(timeIntervalSince1970: 0)) && lesson.date ?? Date(timeIntervalSince1970: 0) > Date() {
                            Text("\(dateText) \(relativeText)")
                                .font(.subheadline)
                                .foregroundColor(lesson.date ?? Date() > Date() ? .blue : .primary)
                        } else {
                            Text(dateText)
                                .font(.subheadline)
                                .foregroundColor(lesson.date ?? Date() > Date() ? .blue : .primary)
                        }
                        
                        
                        if !(lesson.teacher?.isEmpty ?? true) {
                            Text(lesson.teacher ?? "No Teacher")
                                .font(.footnote)
                        }
                        
                        /*HStack {
                         ForEach(lesson.tag!.allObjects as! [Tag]) { tag in
                         Image(systemName: "tag.circle.fill")
                         .foregroundColor(tag.swiftUIColor)
                         }
                         }*/
                    } },
                    icon: {
                        Image(systemName: Lesson.lessonIcon(type: lesson.type))
                            .foregroundColor(.accentColor)
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
}
/*
 struct LessonCell_Previews: PreviewProvider {
 static var previews: some View {
 LessonCell(lesson: Lesson(context: <#T##NSManagedObjectContext#>))
 .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
 .frame(width: 200)
 }
 }*/
