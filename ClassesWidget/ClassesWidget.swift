//
//  ClassesWidget.swift
//  ClassesWidget
//
//  Created by Nick Baughan on 29/09/2020.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    
    var managedObjectContext : NSManagedObjectContext
    
    init(context : NSManagedObjectContext) {
            self.managedObjectContext = context
        }
    
    public typealias Entry = SimpleEntry
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)], predicate: NSPredicate(format: "date > %@", Date() as NSDate), animation: .default)
    private var lessons: FetchedResults<Lesson>
    
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), lessons: Array(lessons.prefix(4)))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), lessons: Array(lessons.prefix(4)))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [SimpleEntry] = [SimpleEntry(date: Date(), lessons: Array(lessons.prefix(4)))]

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let lessons: [Lesson]
}

struct ClassesWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct ClassesWidget: Widget {
    let kind: String = "UpcomingClassesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(context: persistentContainer.viewContext)) { entry in
            UpcomingWidgetView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
    
    var persistentContainer: NSPersistentCloudKitContainer {
        return PersistenceController.shared.container
    }
}
/*
struct ClassesWidget_Previews: PreviewProvider {
    static var previews: some View {
        ClassesWidgetEntryView(entry: SimpleEntry(date: Date(), lessons: Lesson.sampleData(context: PersistenceController.preview.container.viewContext)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}*/
