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
    
    let gridItem: [GridItem] = [GridItem(.adaptive(minimum: 15))]
    
    var body: some View {
            HStack {
                Label(
                    title: { VStack(alignment: .leading, spacing: 0) {
                        Text(lesson.title ?? "Untitled")
                            .font(.headline)
                        
                        if lesson.date ?? Date(timeIntervalSince1970: 0) > Date() {
                            
                            if calendar.isDateInToday(lesson.date ?? Date(timeIntervalSince1970: 0)) {
                                Text("\(dateText) \(relativeText)")
                                    .font(.subheadline)
                                    .foregroundColor(.init("SecondaryColorMidpoint"))
                            } else {
                                Text(dateText)
                                    .font(.subheadline)
                                    .foregroundColor(.init("SecondaryColorMidpoint"))
                            }
                            
                        } else {
                            Text(dateText)
                                .font(.subheadline)
                        }
                        
                        
                        if !(lesson.teacher?.isEmpty ?? true) {
                            Text(lesson.teacher ?? "No Teacher")
                                .font(.footnote)
                        }
                        
                        LazyVGrid(columns: gridItem) {
                            ForEach((lesson.tag?.allObjects as? [Tag] ?? []).sorted {$0.name?.localizedStandardCompare($1.name ?? "") == .orderedAscending}) { tag in
                                Image(systemName: "tag.circle.fill")
                                    .foregroundColor(tag.swiftUIColor)
                            }
                        }
                    } },
                    icon: {
                        Image(systemName: Lesson.lessonIcon(type: lesson.type))
//                            .foregroundColor(.accentColor)
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
/*
 struct LessonCell_Previews: PreviewProvider {
 static var previews: some View {
 LessonCell(lesson: Lesson(context: <#T##NSManagedObjectContext#>))
 .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
 .frame(width: 200)
 }
 }*/
