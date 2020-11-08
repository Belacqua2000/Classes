//
//  AllocateTagView.swift
//  Classes
//
//  Created by Nick Baughan on 12/09/2020.
//

import SwiftUI

struct AllocateTagView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>
    @Binding var selectedTags: [Tag]
    @State private var sheetIsPresented: Bool = false
    
    private struct SelectableTag: Identifiable {
        var id = UUID()
        var tag: Tag
        var isSelected = false
    }
    
    private var selectableTags: [SelectableTag] {
        var t = [SelectableTag]()
        for tag in tags {
            let selectableTag = SelectableTag(tag: tag)
            t.append(selectableTag)
        }
        return t
    }
    
    
    
    var selectedTagsView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(selectedTags) { tag in
                        Button(action: { selectedTag(tag) }, label: {
                            TagIcon(tag: tag)
                        })
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if !tags.isEmpty {
        List {
            ForEach(tags) { tag in
                HStack {
                    Label(tag.name ?? "", systemImage: "tag")
                    Spacer()
                    Button(action: { selectedTag(tag) }, label: {
                        selectedTags.contains(tag) ?
                            Image(systemName: "checkmark.circle.fill") : Image(systemName: "checkmark.circle")
                    })
                }
            }
        }
        } else {
            #if os(macOS)
            Text("No tags have been created.  Add a tag from the sidebar or menu bar.")
                .padding(20)
            #else
            Text("No tags have been created.  Add a tag by pressing the '+' button in the toolbar.")
            #endif
        }
        }
        .sheet(isPresented: $sheetIsPresented) {
            AddTagView(isPresented: $sheetIsPresented, tag: .constant(nil))
        }
        .toolbar {
            #if !os(macOS)
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    sheetIsPresented = true
                }, label: {Label("Add Tag", systemImage: "plus")})
            }
            #endif
        }
        .navigationTitle("Allocate Tags")
        //.navigationBarTitleDisplayMode(.inline)
    }
    
    func selectedTag(_ tag: Tag) {
        withAnimation {
            if let index = selectedTags.firstIndex(of: tag) {
                selectedTags.remove(at: index)
            } else {
                selectedTags.append(tag)
            }
        }
    }
}

struct AllocateTagView_Previews: PreviewProvider {
    static var previews: some View {
        AllocateTagView(selectedTags: .constant([])).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
