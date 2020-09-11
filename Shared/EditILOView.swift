//
//  EditILOView.swift
//  Classes
//
//  Created by Nick Baughan on 09/09/2020.
//

import SwiftUI
import CoreData

struct EditILOView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var lesson: Lesson
    @Binding var isPresented: Bool
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.index, ascending: true)],
        animation: .default)
    private var il: FetchedResults<ILO>
    @State var i: [ILO]
    var ilos: [ILO] { return lesson.ilo?.sortedArray(using: [NSSortDescriptor(key: "index", ascending: true)]) as? [ILO] ?? [] }
    var text: [String] {
        var array: [String] = []
        for ilo in ilos {
            array.append(ilo.title!)
        }
        return(array)
    }
    
    struct editILO: Identifiable {
        var id: UUID
        var text: String
        var index: Int
    }
    @State var ilo: [editILO]
    
    var body: some View {
        VStack(alignment: .leading) {
            #if !os(macOS)
            EditButton()
            #endif
            List {
                ForEach(ilo) { il in
                    HStack {
                        Text("\(il.index + 1).")
                        NavigationLink(
                            destination: EditILOTextView(ilo: $ilo[il.index]),
                            label: {
                                Text(il.text)
                            })
                    }
                }
                .onDelete(perform: delete)
                Button(action: addILO) { Label("Add ILO", systemImage: "plus")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isPresented = false
                    }, label: {
                        Text("Cancel")
                    })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save, label: {
                        Text("Save")
                    })
                }
            }
            .navigationTitle("Edit ILOs")
        }
    }
    func addILO() {
        /*let newIlo = ILO(context: viewContext)
        newIlo.id = UUID()
        newIlo.lesson = lesson
        newIlo.title = ""*/
        let newIlo = editILO(id: UUID(), text: "", index: ilo.count)
        ilo.append(newIlo)
    }
    
    func save() {
        let lessonILOs = lesson.ilo!.allObjects as! [ILO]
        var lessonILOIds: [UUID] = []
        for ilo in lessonILOs {
            lessonILOIds.append(ilo.id!)
        }
        for editingIlo in ilo {
            if lessonILOIds.contains(editingIlo.id) {
                if let ilo = lessonILOs.first(where: { $0.id == editingIlo.id }) {
                    ilo.update(in: viewContext, text: editingIlo.text, index: Int16(editingIlo.index), lesson: lesson)
                }
            } else {
                ILO.create(in: viewContext, title: editingIlo.text, index: editingIlo.index, lesson: lesson)
            }
        }
        isPresented = false
    }
    
    func delete(at offsets: IndexSet) {
        print(offsets)
        ilo.remove(atOffsets: offsets)
    }
    
}

struct EditILOTextView: View {
    @Binding var ilo: EditILOView.editILO
    var body: some View {
        Form {
            TextField("Enter Text", text: $ilo.text)
        }
    }
}

/*struct EditILOView_Previews: PreviewProvider {
 static var previews: some View {
 EditILOView()
 }
 }*/
