//
//  SidebarNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 05/09/2020.
//

import SwiftUI

struct SidebarNavigation: View {
    
    //Environment
    @Environment(\.managedObjectContext) var viewContext
    
    //Sidebar struct
    struct SidebarItem: Hashable {
        enum SidebarTypes {
            case summary
            case all
            case ilo
            case lessonType
            case tag
        }
        var sidebarType: SidebarTypes
        var lessonTypes: Lesson.LessonType?
        var tag: Tag?
    }
    
    // State properties
    @State var addTagShowing: Bool = false
    @State var selectedTag: Tag?
    @State private var deleteAlertShown = false
    @State private var settingsShown = false
    
    // Tag Fetch Request
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)], animation: .default)
    private var tags: FetchedResults<Tag>
    
    @State var selection: SidebarItem? = SidebarItem(sidebarType: .all, lessonTypes: nil, tag: nil)
    
    var sidebar: some View {
        List(selection: $selection) {
            NavigationLink(destination: SummaryView()) {
                Label("Summary", systemImage: "chart.pie")
            }
            .tag(SidebarItem(sidebarType: .summary, lessonTypes: nil))
            
            NavigationLink(destination: LessonsView(filter: LessonsFilter(filterType: .all, lessonType: nil))) {
                Label("All Lessons", systemImage: "books.vertical")
            }
            .tag(SidebarItem(sidebarType: .all, lessonTypes: nil))
            
            NavigationLink(destination: ILOsView()) {
                Label("Learning Outcomes", systemImage: "doc")
            }
            .tag(SidebarItem(sidebarType: .ilo, lessonTypes: nil))
            
            Section(header: Text("Class Type")) {
                ForEach(Lesson.LessonType.allCases) { lesson in
                    NavigationLink(destination: LessonsView(filter: LessonsFilter(filterType: .lessonType, lessonType: lesson))) {
                        Label(Lesson.lessonTypePlural(type: lesson.rawValue), systemImage: Lesson.lessonIcon(type: lesson.rawValue))
                    }
                    .tag(SidebarItem(sidebarType: .lessonType, lessonTypes: lesson))
                }
            }
            
            Section(header: Text("Tags")) {
                ForEach(tags) { tag in
                    NavigationLink(destination:  LessonsView(filter: LessonsFilter(filterType: .tag, lessonType: nil, tag: tag))) {
                        Label(
                            title: { Text(tag.name ?? "Untitled") },
                            icon: {
                                Image(systemName: "tag")
                                    .foregroundColor(tag.swiftUIColor)
                            }
                        )
                    }
                    .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                        Button(action: {editTag(tag: tag)}, label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        })
                        Button(action: {deleteTagAlert(tag: tag)}, label: {
                            Label("Delete", systemImage: "trash")
                        })
                    }/*@END_MENU_TOKEN@*/)
                    .tag(SidebarItem(sidebarType: .tag, lessonTypes: nil, tag: tag))
                }
                .onDelete(perform: delete)
                .alert(isPresented: $deleteAlertShown) {
                    Alert(title: Text("Delete Tag"), message: Text("Are you sure you want to delete?  This action cannot be undone."), primaryButton: .destructive(Text("Delete"), action: deleteTag), secondaryButton: .cancel(Text("Cancel"), action: {deleteAlertShown = false; selectedTag = nil}))
                }
                Button(action: addTag, label: {
                    Label("Add Tag", systemImage: "plus.circle")
                })
            }
            .listStyle(SidebarListStyle())
        }
        .sheet(isPresented: $addTagShowing, onDismiss: {
            selectedTag = nil
        }, content: {
            AddTagView(isPresented: $addTagShowing, tag: $selectedTag).environment(\.managedObjectContext, viewContext)
        })
    }
    
    var body: some View {
        NavigationView {
            sidebar
                .navigationTitle("Classes")
                .toolbar {
                    #if !os(macOS)
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {settingsShown = true}, label: {
                            Label("Settings", systemImage: "gear")
                        })
                        .sheet(isPresented: $settingsShown) {
                            NavigationView {
                                SettingsView(viewIsShown: $settingsShown)
                            }
                        }
                    }
                    #endif
                }
            LessonsView(filter: LessonsFilter(filterType: .all, lessonType: nil))
        }
    }
    
    func delete(offsets: IndexSet) {
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
    
    struct SidebarNavigation_Previews: PreviewProvider {
        //@State static var selection: Set<SidebarNavigation.SidebarItem>
        static var previews: some View {
            SidebarNavigation()
        }
    }
    
    struct LessonDrop: DropDelegate {
        func performDrop(info: DropInfo) -> Bool {
            return true
        }
        
        
    }
}
