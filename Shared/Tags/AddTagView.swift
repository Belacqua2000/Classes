//
//  AddTagView.swift
//  Shared
//
//  Created by Nick Baughan on 12/09/2020.
//

import SwiftUI

struct AddTagView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresented: Bool
    @Binding var tag: Tag?
    @State var tagName: String = ""
    @State var tagColor: Color = Color.red
    var isEditing: Bool {
        return tag != nil
    }
    
    var navTitle: String {
        tag == nil ? "Add Tag" : "Edit Tag"
    }
    
    var cancelButton: some View {
        Button("Cancel", action: cancel)
    }
    
    var saveButton: some View {
        Button("Save", action: save)
            .disabled(tagName.isEmpty)
    }
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    var sidebar: Bool {
        #if os(iOS)
        return horizontalSizeClass == .regular ? true : false
        #else
        return true
        #endif
    }
    
    var formFooter: Text {
        Text("Add tags to organise your lessons.  Each lesson can have multiple tags.\n\nExamples of Tag Category:\n• Lesson Topic\n• Week Number\n• Notes Location\n\nTo view lessons by tag, choose a tag from the \(sidebar ? "sidebar" : "main screen"), or press \(Image(systemName: "line.horizontal.3.decrease.circle")) in the toolbar from the lesson list to filter further.")
    }
    
    var form: some View {
        Form {
            #if os(macOS)
            Text(navTitle)
                .font(.headline)
            #endif
            Section(header: Text("Tag Details"), footer: formFooter) {
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
            #else
            ColorPicker(selection: $tagColor, label: {
                Label("Tag Color", systemImage: "paintpalette")
            })
            #endif
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
        }
        .onAppear(perform: {
            if let tag = tag {
                tagName = tag.name ?? ""
                tagColor = tag.swiftUIColor ?? Color.red
            }
        })
    }
    
    var body: some View {
        #if !os(macOS)
        NavigationView {
            form
                .navigationTitle(navTitle)
        }
        #else
        form
            .padding()
        #endif
    }
    
    func save() {
        //self.hideKeyboard()
        isPresented = false
        if tag != nil {
            tag?.update(in: viewContext, name: tagName, color: tagColor)
        } else {
            Tag.create(in: viewContext, name: tagName, color: tagColor)
        }
    }
    
    func cancel() {
        //self.hideKeyboard()
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddTagView_Previews: PreviewProvider {
    static var previews: some View {
        #if !os(macOS)
        NavigationView {
            AddTagView(isPresented: .constant(true), tag: .constant(nil))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        AddTagView(isPresented: .constant(true), tag: .constant(nil))
        #endif
    }
}
