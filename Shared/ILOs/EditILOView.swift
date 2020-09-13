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
    var ilo: ILO?
    var lesson: Lesson
    
    var saveButton: some View {
        Button(action: add, label: {
            Text("Save")
        })
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
            Section(header: Text("Add ILO").font(.headline)) {
                TextField("ILO Text", text: $iloText)
            }
            HStack {
                Spacer()
                cancelButton
                saveButton
            }
            #else
            TextField("ILO Text", text: $iloText)
                .navigationTitle("Add ILO")
            #endif
        }
        .frame(idealWidth: 300, idealHeight: 50)
        .padding()
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
        lesson.updateILOIndices(in: viewContext)
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
