//
//  EditILOView.swift
//  Classes
//
//  Created by Nick Baughan on 10/09/2020.
//

import SwiftUI

struct EditILOView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var iloText: String = ""
    @Binding var isPresented: Bool
    @Binding var ilo: ILO?
    var lesson: Lesson
    
    var saveButton: some View {
        Button(action: add, label: {
            Text("Save")
        })
        .disabled(iloText == "")
        .keyboardShortcut(.defaultAction)
    }
    
    var cancelButton: some View {
        Button(action: cancel, label: {
            Text("Cancel")
        })
        .keyboardShortcut(.cancelAction)
    }
    
    var body: some View {
        Form {
            #if os(macOS)
            Section(header: Text("Add Learning Outcome").font(.headline)) {
                TextField("Outcome Text", text: $iloText)
            }
            HStack {
                Spacer()
                cancelButton
                saveButton
            }
            #else
            TextField("Outcome Text", text: $iloText)
                .navigationTitle("Add Outcome")
            #endif
        }
        .onAppear(perform: {
            if let ilo = ilo {
                iloText = ilo.title ?? ""
            }
        })
        .frame(idealWidth: 300, idealHeight: 50)
        .toolbar {
            #if !os(macOS)
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
            #endif
        }
    }
    func add() {
        if let ilo = ilo {
            ilo.update(in: viewContext, text: iloText, index: ilo.index, lesson: lesson)
        } else {
            ILO.create(in: viewContext, title: iloText, index: lesson.ilo?.count ?? 0, lesson: lesson)
        }
        lesson.updateILOIndices(in: viewContext, save: true)
        isPresented = false
    }
    
    func cancel() {
        isPresented = false
    }
}
/*
struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditILOView()
    }
}*/
