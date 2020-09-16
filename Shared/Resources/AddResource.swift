//
//  AddResource.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 12/09/2020.
//

import SwiftUI

struct AddResource: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var resourceText: String = ""
    @State var resourceURL: String = ""
    @Binding var isPresented: Bool
    @Binding var resource: Resource?
    var lesson: Lesson?
    
    var saveButton: some View {
        Button(action: save, label: {
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
            Section(header: Text("Add Resource").font(.headline)) {
                TextField("Resource Name", text: $resourceText)
                TextField("Resource URL", text: $resourceURL)
            }
            HStack {
                Spacer()
                cancelButton
                saveButton
            }
            #else
            TextField("Resource Name", text: $resourceText)
                .navigationTitle("Add ILO")
            TextField("Resource URL", text: $resourceURL)
                .textContentType(.URL)
                .keyboardType(.URL)
                .textCase(.lowercase)
            #endif
        }
        .onAppear(perform: {
            if let resource = resource {
                resourceText = resource.name ?? ""
                resourceURL = resource.url?.absoluteString ?? ""
            }
        })
        .frame(idealWidth: 300, idealHeight: 100)
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
    func save() {
        let url = URL(string: resourceURL)
        if let resource = resource {
            resource.update(in: viewContext, name: resourceText, lesson: lesson!, url: url)
        } else {
            Resource.create(in: viewContext, title: resourceText, lesson: lesson!, url: url)
        }
        lesson!.updateILOIndices(in: viewContext)
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
        AddResource(isPresented: .constant(true), lesson: nil)
        #endif
    }
}
