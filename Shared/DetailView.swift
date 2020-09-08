//
//  DetailView.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var isEditing: Bool = false
    @ObservedObject var lesson: Lesson
    @State var newILOText: String = ""
    @State var newILOSaveButtonShown: Bool = false
    var ilo: [ILO] { return lesson.ilo!.allObjects as! [ILO] }
    var body: some View {
        ScrollView {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: Lesson.lessonIcon(type: lesson.type))
                    .padding()
                VStack(alignment: .leading) {
                    Text(lesson.title ?? "No Title")
                        .font(.largeTitle)
                    Text(itemFormatter.string(from: lesson.date ?? Date(timeIntervalSince1970: 0)))
                        .font(.title2)
                }
                Spacer()
            }
            HStack {
                Text("ILOs:")
                    .font(.headline)
                Button(action: {
                        isEditing.toggle()
                    newILOText = ""
                }, label: {
                    isEditing ? Text("Save") : Text("Edit")
                })
            }
            List {
                ForEach(ilo) { i in
                    if let ilo = i as ILO {
                        Text(ilo.title ?? "")
                    }
                }
                .onDelete { indexSet in
                    deleteILOs(offsets: indexSet)
                }
                #if os(iOS)
                if isEditing {
                    HStack {
                        TextField("Add Outcome", text: $newILOText)
                            .onChange(of: newILOText, perform: { value in
                                newILOSaveButtonShown = !newILOText.isEmpty
                        })
                        if newILOSaveButtonShown {
                            Button(action: {createILO(index: lesson.ilo?.count ?? 0)}) {
                                Text("Save")
                                    .keyboardShortcut(.defaultAction)
                            }
                        }
                        
                    }
                }
                #endif
            }
            #if os(macOS)
            if isEditing {
                HStack {
                    TextField("Add Outcome", text: $newILOText)
                        .onChange(of: newILOText, perform: { value in
                            newILOSaveButtonShown = !newILOText.isEmpty
                    })
                    if newILOSaveButtonShown {
                        Button(action: {createILO(index: lesson.ilo?.count ?? 0)}) {
                            Text("Add")
                                .keyboardShortcut(.defaultAction)
                        }
                    }
                    
                }
            }
            #endif
        }
        }
        .navigationTitle(lesson.title!)
        .padding(.horizontal)
        .toolbar {
            Button(action: {lesson.toggleWatched(context: managedObjectContext)}, label: {
                !(lesson.watched) ?
                    Label("Mark as Watched", systemImage: "checkmark.circle") : Label("Mark as Unwatched", systemImage: "checkmark.circle.fill")
            })
        }
    }
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    func createILO(index: Int) {
        ILO.create(in: managedObjectContext, title: newILOText, index: index, lesson: lesson)
        newILOText = ""
    }
    
    private func deleteILOs(offsets: IndexSet) {
        withAnimation {
            offsets.map { ilo[$0] }.forEach(managedObjectContext.delete)
            
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

/*
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(lesson: .constant(nil))
    }
}*/
