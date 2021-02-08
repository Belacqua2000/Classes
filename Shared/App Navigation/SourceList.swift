//
//  SourceList.swift
//  Classes
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct SourceList: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var selection: Item?
    @Binding var addTagShowing: Bool
    @Binding var selectedTag: Tag?
    @Binding var deleteAlertShown: Bool
    
    // Tag Fetch Request
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))], animation: .default)
    private var tags: FetchedResults<Tag>
    
    struct Item: Hashable {
        enum SidebarTypes {
            case summary
            case all
            case ilo
            case lessonType
            case tag
            
            case today
            case unwatched
            case unwritten
        }
        var sidebarType: SidebarTypes
        var lessonTypes: Lesson.LessonType?
        var tag: Tag?
    }
    
    var body: some View {
        
        List(selection: $selection) {
            
            NavigationLink(
                destination: LessonsView(listType: LessonsListType(filterType: .all, lessonType: nil)).environmentObject(LessonsListHelper(context: viewContext)),
                tag: Item(sidebarType: .all),
                selection: $selection,
                label: {
                    Label(
                        title: {Text("All Lessons")},
                        icon: {
                            Image(systemName: "books.vertical")
                        })
                })
            
            SmartGroupsList(selection: $selection)
            
            LessonTypeList()
            
            
            Section(header: Text("Tags")) {
                ForEach(tags) { tag in
                    
                    NavigationLink(destination:  LessonsView(listType: LessonsListType(filterType: .tag, lessonType: nil, tag: tag)).environmentObject(LessonsListHelper(context: viewContext)), label: {
                        if #available(iOS 14.3, *) {
                            Label(tag.name ?? "Untitled", systemImage: "tag")
                        } else {
                            Label(
                                title: { Text(tag.name ?? "Untitled") },
                                icon: { Image(systemName: "tag")
                                    .foregroundColor(tag.swiftUIColor)
                                }
                            )
                        }
                        
                    })
                    .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                        Button(action: {editTag(tag: tag)}, label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        })
                        Button(action: {deleteTagAlert(tag: tag)}, label: {
                            Label("Delete", systemImage: "trash")
                        })
                    }/*@END_MENU_TOKEN@*/)
                    .tag(Item(sidebarType: .tag, lessonTypes: nil, tag: tag))
                    .listItemTint(tag.swiftUIColor)
                }
                .onDelete(perform: delete)
                Button(action: addTag, label: {
                    Label("Add Tag", systemImage: "plus.circle")
                })
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .alert(isPresented: $deleteAlertShown) {
            Alert(title: Text("Delete Tag"), message: Text("Are you sure you want to delete?  This action cannot be undone."), primaryButton: .destructive(Text("Delete"), action: deleteTag), secondaryButton: .cancel(Text("Cancel"), action: {deleteAlertShown = false; selectedTag = nil}))
        }
        .sheet(isPresented: $addTagShowing, onDismiss: {
            selectedTag = nil
        }, content: {
            AddTagView(isPresented: $addTagShowing, tag: $selectedTag).environment(\.managedObjectContext, viewContext)
        })
        
    }
    
    private func delete(offsets: IndexSet) {
        offsets.map { tags[$0] }.forEach { tag in
            deleteTagAlert(tag: tag)
        }
    }

    private func addTag() {
        selectedTag = nil
        addTagShowing = true
    }

    private func editTag(tag: Tag) {
        selectedTag = tag
        addTagShowing = true
    }

    private func deleteTagAlert(tag: Tag) {
        selectedTag = tag
        deleteAlertShown = true
    }

    private func deleteTag() {
        withAnimation {
            selectedTag?.delete(context: viewContext)
        }
        selectedTag = nil
    }
}

struct SourceList_Previews: PreviewProvider {
    static var previews: some View {
        SourceList(selection: .constant(.init(sidebarType: .all, lessonTypes: nil, tag: nil)), addTagShowing: .constant(false), selectedTag: .constant(nil), deleteAlertShown: .constant(false))
    }
}
