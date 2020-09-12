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
                        LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil)),
                    label: {
                        Label("All Classes", systemImage: "books.vertical")
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
                                LessonsView(filter: LessonsView.Filter(filterType: .lessonType, lessonType: nil, tag: tag)),
                            label: {
                                Label(title: { Text(tag.name ?? "Untitled") },
                                    icon: {
                                        Image(systemName: "tag")
                                            .foregroundColor(tag.swiftUIColor)
                                    }
                                )
                            })
                            .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                                Button(action: {tag.delete(context: viewContext)}, label: {
                                    Label("Delete", systemImage: "trash")
                                })
                            }/*@END_MENU_TOKEN@*/)
                            .tag(SidebarItem(sidebarType: .tag, lessonTypes: nil, tag: tag))
                    }
                    .onDelete(perform: delete)
                    Button(action: {addTagShowing = true}, label: {
                        Label("Add Tag", systemImage: "plus.circle")
                    })
                    .tag(SidebarItem(sidebarType: .tag, lessonTypes: nil, tag: nil))
                    .sheet(isPresented: $addTagShowing, content: {
                        AddTagView(isPresented: $addTagShowing)
                    })
                }
            }
            .navigationTitle("Classes")
            .frame(minWidth: 100, idealWidth: 150, maxHeight: .infinity)
            .listStyle(SidebarListStyle())
            LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil))
            if selection != [SidebarItem(sidebarType: .ilo, lessonTypes: nil)] {
                Text("Select a Class")
            }
        }
        .onAppear(perform: {
            selection = [SidebarItem(sidebarType: .all, lessonTypes: nil)]
            print(tags)
        })
    }
    
    func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { tags[$0] }.forEach { tag in
                tag.delete(context: viewContext)
            }
        }
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
