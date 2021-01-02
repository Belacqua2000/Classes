//
//  UpcomingWidgetView.swift
//  Classes
//
//  Created by Nick Baughan on 29/09/2020.
//

import WidgetKit
import SwiftUI

struct UpcomingWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: Provider.Entry
    
    var nextLesson: [Lesson] {
        if let first = entry.lessons.first {
            return [first]
        }
        return []
    }
    
    var nextTwoLessons: [Lesson] {
        return Array(entry.lessons.prefix(2))
    }
    
    var nextFewLessons: [Lesson] {
        return Array(entry.lessons.prefix(4))
    }
    
    var body: some View {
        ZStack {
            Color("UpcomingBackground")
            
            VStack(alignment: .leading) {
                Text("Up Next:")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.black)
                
                switch widgetFamily {
                case .systemSmall:
                    ForEach(nextLesson) { lesson in
                        UpcomingLessonSession(lesson: lesson)
                    }
                case .systemMedium:
                    ForEach(nextTwoLessons) { lesson in
                        UpcomingLessonSession(lesson: lesson)
                    }
                case .systemLarge:
                    ForEach(nextFewLessons) { lesson in
                        UpcomingLessonSession(lesson: lesson)
                    }
                default:
                    ForEach(nextLesson) { lesson in
                        UpcomingLessonSession(lesson: lesson)
                    }
                }
            }
            .padding()
        }
    }
}

struct UpcomingWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UpcomingWidgetView(entry: SimpleEntry(date: Date(), lessons: Lesson.sampleData(context: PersistenceController.preview.container.viewContext)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            UpcomingWidgetView(entry: SimpleEntry(date: Date(), lessons: Lesson.sampleData(context: PersistenceController.preview.container.viewContext)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            UpcomingWidgetView(entry: SimpleEntry(date: Date(), lessons: Lesson.sampleData(context: PersistenceController.preview.container.viewContext)))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
        .environment(\.colorScheme, .dark)
    }
}

struct UpcomingLessonSession: View {
    @Environment(\.widgetFamily) var widgetFamily
    var lesson: Lesson
    var body: some View {
        VStack(alignment: .leading) {
            Label(
                title: { Text("Untitled Lesson")
                    .bold() },
                icon: { Image(systemName: Lesson.lessonIcon(type: lesson.type)) })
                .minimumScaleFactor(0.8)
            if widgetFamily == .systemSmall {
                Spacer(minLength: 0)
                Text(lesson.location ?? "")
                    .font(.caption)
                Spacer(minLength: 0)
                Text("in \(lesson.date!, style: .relative)")
                    .bold()
                    .font(.subheadline)
                    .foregroundColor(Color("CustomRed"))
                
            } else {
                Spacer(minLength: 0)
                HStack {
                    Text("in \(lesson.date!, style: .relative)")
                        .bold()
                        .font(.subheadline)
                        .foregroundColor(Color("CustomRed"))
                    
                    Spacer()
                    
                    Text(lesson.location ?? "")
                        .font(.caption)
                }
            }
        }
        //.redacted(reason: .placeholder)
        .padding(.all, 5)
        .background(ContainerRelativeShape().fill(Color("SecondaryColor")))
    }
}
