//
//  SidebarNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 05/09/2020.
//

import SwiftUI

struct SidebarNavigation: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
        animation: .default)
    private var lessons: FetchedResults<Lesson>
    
    var body: some View {
        NavigationView {
            List {
                Label("All Classes", systemImage: "books.vertical")
                Section(header: Text("Class Type")) {
                    Label("Lectures", systemImage: "studentdesk")
                    Label("Clinical Skills", systemImage: "stethoscope")
                    Label("Tutorials", systemImage: "person.3")
                }
            }
            .listStyle(SidebarListStyle())
            List {
                ForEach(lessons) { lesson in
                    Label("Item at \(lesson.date!, formatter: itemFormatter)", systemImage: "books.vertical")
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(InsetListStyle())
            .toolbar {
                #if os(iOS)
                EditButton()
                #endif
                
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            Text("Detail")
                .listStyle(PlainListStyle())
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Lesson(context: viewContext)
            newItem.date = Date()

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
}

struct SidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        SidebarNavigation()
    }
}
