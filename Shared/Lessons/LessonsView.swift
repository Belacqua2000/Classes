//
//  LessonsView.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct LessonsView: View {
    
    struct Filter: Hashable {
        enum FilterTypes {
            case all, tag, lessonType, watched
        }
        var filterType: FilterTypes
        var lessonType: Lesson.LessonType?
    }
    
    @State var selection = Set<UUID>()
    @State var sheetIsPresented: Bool = false
    @State var filter: Filter
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
        animation: .default)
    private var lessons: FetchedResults<Lesson>
    
    private var filteredLessons: [Lesson] {
        switch filter.filterType {
        case .all:
            return lessons.filter({ !$0.isDeleted })
        case .tag:
            return lessons.filter({ !$0.isDeleted })
        case .lessonType:
            switch filter.lessonType {
            case .lecture:
                return lessons.filter({ $0.type == Lesson.LessonType.lecture.rawValue })
            case .tutorial:
                return lessons.filter({ $0.type == Lesson.LessonType.tutorial.rawValue })
            case .pbl:
                return lessons.filter({ $0.type == Lesson.LessonType.pbl.rawValue })
            case .cbl:
                return lessons.filter({ $0.type == Lesson.LessonType.cbl.rawValue })
            case .lab:
                return lessons.filter({ $0.type == Lesson.LessonType.lab.rawValue })
            case .none:
                return lessons.filter({ !$0.isDeleted })
            }
        case .watched:
            return lessons.filter({ $0.watched })
        }
    }
    
    var body: some View {
        VStack {
            if lessons.count != 0 {
                List(selection: $selection) {
                    ForEach(filteredLessons) { lesson in
                        NavigationLink(
                            destination:
                                DetailView(lesson: lesson)
                            ,
                            label: {
                                LessonCell(lesson: lesson)
                            })
                            .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                                Button(action: {lesson.toggleWatched(context: viewContext)}, label: {
                                    !lesson.watched ? Label("Mark Watched", systemImage: "checkmark.circle")
                                    : Label("Mark Unwatched", systemImage: "checkmark.circle")
                                })
                                Button(action: {lesson.delete(context: viewContext)}, label: {
                                    Label("Delete", systemImage: "trash")
                                })
                            }/*@END_MENU_TOKEN@*/)
                        //#endif
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(InsetListStyle())
            } else {
                HStack {
                    Text("No Classes.  Click the + button in the toolbar to create one.")
                        .padding()
                        .multilineTextAlignment(.center)
                }
            }
        }
        .sheet(isPresented: $sheetIsPresented, content: {
            AddLessonView(isPresented: $sheetIsPresented, type: .lecture)
                .frame(minWidth: 200, idealWidth: 400, minHeight: 200, idealHeight: 250)
        })
        .toolbar {
            #if os(iOS)
            //EditButton()
            #endif
            
            Button(action: addLesson, label: {
                Label("Add Lesson", systemImage: "plus")
            })
            .keyboardShortcut(KeyboardShortcut("n", modifiers: [.command, .shift]))
    }
        .navigationTitle("Lessons")
        //.navigationSubtitle("\(lessons.count) Lessons")
    }
    
    private func addLesson() {
        sheetIsPresented = true
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredLessons[$0] }.forEach { lesson in
                lesson.delete(context: viewContext)
            }
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
