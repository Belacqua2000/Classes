//
//  SidebarNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 05/09/2020.
//

import SwiftUI

struct SidebarNavigation: View {
    
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
    
    @Environment(\.managedObjectContext) var viewContext
    
    @State var addTagShowing: Bool = false
    @State var selectedTag: Tag?
    @State private var deleteAlertShown = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>
    
    @State var selection = Set<SidebarItem>()
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                NavigationLink(
                    destination:
                        SummaryView(),
                    label: {
                        Label("Summary", systemImage: "chart.pie")
                    })
                    .tag(SidebarItem(sidebarType: .summary, lessonTypes: nil))
                NavigationLink(
                    destination:
                        LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil)),
                    label: {
                        Label("All Lessons", systemImage: "books.vertical")
                    })
                    .tag(SidebarItem(sidebarType: .all, lessonTypes: nil))
                
                NavigationLink(
                    destination: ILOsView(),
                    label: {
                        Label("ILOs", systemImage: "doc")
                    })
                    .tag(SidebarItem(sidebarType: .ilo, lessonTypes: nil))
                
                Section(header: Text("Class Type")) {
                    ForEach(Lesson.LessonType.allCases) { lesson in
                        NavigationLink(
                            destination:
                                LessonsView(filter: LessonsView.Filter(filterType: .lessonType, lessonType: lesson)),
                            label: {
                                Label("\(lesson.rawValue)s", systemImage: Lesson.lessonIcon(type: lesson.rawValue))
                            })
                            .tag(SidebarItem(sidebarType: .lessonType, lessonTypes: lesson))
                    }
                }
                
                Section(header: Text("Tags")) {
                    ForEach(tags) { tag in
                        NavigationLink(
                            destination:
                                LessonsView(filter: LessonsView.Filter(filterType: .tag, lessonType: nil, tag: tag)),
                            label: {
                                Label(title: { Text(tag.name ?? "Untitled") },
                                    icon: {
                                        Image(systemName: "tag")
                                            .foregroundColor(tag.swiftUIColor)
                                    }
                                )
                            })
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
                    Button(action: {addTagShowing = true}, label: {
                        Label("Add Tag", systemImage: "plus.circle")
                    })
                    .sheet(isPresented: $addTagShowing, onDismiss: {
                        selectedTag = nil
                    }, content: {
                        AddTagView(isPresented: $addTagShowing, tag: $selectedTag)
                    })
                }
            }
            .navigationTitle("Classes")
            .frame(minWidth: 100, idealWidth: 150, maxHeight: .infinity)
            .listStyle(SidebarListStyle())
            /*LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil))
            if selection != [SidebarItem(sidebarType: .ilo, lessonTypes: nil)] {
                Text("Select a Class")
            }*/
        }
        .onAppear(perform: {
            selection = [SidebarItem(sidebarType: .all, lessonTypes: nil)]
        })
    }
    
    func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { tags[$0] }.forEach { tag in
                tag.delete(context: viewContext)
            }
        }
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
        selectedTag?.delete(context: viewContext)
        selectedTag = nil
    }
    
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
