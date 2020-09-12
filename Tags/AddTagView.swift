//
//  AddTagView.swift
//  Shared
//
//  Created by Nick Baughan on 12/09/2020.
//

import SwiftUI

struct AddTagView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var isPresented: Bool
    @State var tagName: String = ""
    @State var tagColor: Color = Color.red
    
    var form: some View {
        Form {
            TextField("Tag Name", text: $tagName)
            #if os(macOS)
            HStack {
                Label("Tag Color", systemImage: "tag.circle")
                ColorPicker(selection: $tagColor, label: {
                    Label("Tag Color", systemImage: "tag.circle") // When this is shown it is not inline
                })
                .labelsHidden()
                .frame(width: 80, height: 20)
            }
            HStack {
                Spacer()
                Button("Add", action: save).keyboardShortcut(.defaultAction)
                Button("Cancel", action: cancel).keyboardShortcut(.cancelAction)
            }
            #else
            ColorPicker(selection: $tagColor, label: {
                Label("Tag Color", systemImage: "tag.circle")
            })
            #endif
        }
        .padding()
    }
    
    var body: some View {
        #if !os(macOS)
        NavigationView {
            form
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add", action: save)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", action: cancel)
                    }
                }
                .navigationTitle("Add Tag")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        form
        #endif
    }
    
    func save() {
        Tag.create(in: viewContext, name: tagName, color: tagColor)
        isPresented = false
    }
    
    func cancel() {
        isPresented = false
    }
}

struct AddTagView_Previews: PreviewProvider {
    static var previews: some View {
        #if !os(macOS)
        NavigationView {
            AddTagView(isPresented: .constant(true))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        AddTagView(isPresented: .constant(true))
        #endif
    }
}
