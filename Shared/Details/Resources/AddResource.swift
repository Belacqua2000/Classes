//
//  AddResource.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 12/09/2020.
//

import SwiftUI

struct AddResource: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var resourceText = String()
    @State var resourceURL = String()
    @Binding var isPresented: Bool
    @Binding var resource: Resource?
    var lesson: Lesson?
    
    var saveButton: some View {
        Button(action: save, label: {
            Text("Save")
        })
        .disabled(resourceText == "")
        .keyboardShortcut(.defaultAction)
    }
    
    var cancelButton: some View {
        Button(action: cancel, label: {
            Text("Cancel")
        })
        .keyboardShortcut(.cancelAction)
    }
    
    let footerText: Text = Text("Add useful links to save to this lesson to easily find later.\n\nExamples:\n• Links to lecture slides\n• Links to notes\n• Links to websites")
    
    var form: some View {
        Form {
            #if os(macOS)
            Section(header: Text("Add Link").font(.headline), footer: footerText) {
                TextField("Link Name", text: $resourceText)
                TextField("https://www.example.co.uk", text: $resourceURL)
            }
            #else
            Section(footer: footerText) {
                TextField("Link Name", text: $resourceText)
                    .navigationTitle("Add ILO")
                TextField("https://www.example.co.uk", text: $resourceURL)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .textCase(.lowercase)
            }
            #endif
        }
        .onAppear(perform: {
            if let resource = resource {
                resourceText = resource.name ?? ""
                resourceURL = resource.url?.absoluteString ?? ""
            }
        })
        .frame(idealWidth: 300, idealHeight: 100)
        .toolbar(id: "AddResourceToolbar") {
            ToolbarItem(id: "AddResourceSave", placement: .confirmationAction) {
                saveButton
            }
            ToolbarItem(id: "AddResourceCancel", placement: .cancellationAction) {
                cancelButton
            }
        }
    }
    
    var body: some View {
        #if os(iOS)
        form
        #else
        form
            .padding()
        #endif
    }
    func save() {
        let url = URL(string: resourceURL)
        if let resource = resource {
            resource.update(in: viewContext, name: resourceText, lesson: lesson!, url: url)
        } else {
            Resource.create(in: viewContext, title: resourceText, lesson: lesson!, url: url)
        }
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


struct AddResource_Previews: PreviewProvider {
    static var previews: some View {
        #if !os(macOS)
        NavigationView {
            AddResource(isPresented: .constant(true), resource: .constant(nil), lesson: nil)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        AddResource(isPresented: .constant(true), resource: .constant(nil), lesson: nil)
        #endif
    }
}
