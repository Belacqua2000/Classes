//
//  LessonsView.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct LessonsView: View {
    @State var sheetIsPresented: Bool = false
    private var predicate: String
    @Environment(\.managedObjectContext) private var viewContext
    /*@FetchRequest(
     sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
     animation: .default)*/
    private var fetchRequest: FetchRequest<Lesson>
    private var lessons: FetchedResults<Lesson> { return fetchRequest.wrappedValue }
    
    var body: some View {
        List {
            ForEach(lessons) { lesson in
                /*#if os(macOS)
                NavigationLink(
                    destination:
                        DetailView(lesson: lesson)
                        .background(Color(.textBackgroundColor))
                    ,
                    label: {
                        LessonCell(lesson: lesson)
                    })
                #else*/
                NavigationLink(
                    destination:
                        DetailView(lesson: lesson)
                    ,
                    label: {
                        LessonCell(lesson: lesson)
                            .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                                Button(action: {lesson.toggleWatched(context: viewContext)}, label: {
                                    !lesson.watched ? Label("Mark Watched", systemImage: "checkmark.circle")
                                    : Label("Mark Unwatched", systemImage: "checkmark.circle")
                                })
                            }/*@END_MENU_TOKEN@*/)
                    })
                //#endif
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle(
            "\(predicate)"
        )
        .sheet(isPresented: $sheetIsPresented, content: {
            AddLessonView(isPresented: $sheetIsPresented, type: .lecture)
                .frame(minWidth: 200, idealWidth: 400, minHeight: 200, idealHeight: 250)
        })
        .listStyle(InsetListStyle())
        .toolbar {
            #if os(iOS)
            //EditButton()
            #endif
            
            Button(action: addLesson, label: {
                Label("Add Lesson", systemImage: "plus")
            })
        }
    }
    
    private func addLesson() {
        sheetIsPresented = true
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { lessons[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    init(predicate: String) {
        self.predicate = predicate
        if predicate == "All Classes" {
            fetchRequest = FetchRequest<Lesson>(entity: Lesson.entity(), sortDescriptors: [], predicate: nil)
        } else {
        fetchRequest = FetchRequest<Lesson>(entity: Lesson.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type BEGINSWITH %@", predicate))
        }
    }
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(predicate: "All Classes")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
