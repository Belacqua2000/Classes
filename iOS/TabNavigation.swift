//
//  TabNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 08/09/2020.
//

import SwiftUI

struct TabNavigation: View {
    @State private var selection: Tab = .all
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil))
            }
            .tabItem {
                Label("All Lessons", systemImage: "books.vertical")
            }
            .tag(Tab.all)
            
            NavigationView {
                List {
                    Section(header: Text("Lesson Types")) {
                    LessonTypeNavigationList()
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
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Lesson Types")
            }
            .tabItem {
                Label("Browse", systemImage: "list.bullet")
            }
            .tag(Tab.lessonTypes)
            
            NavigationView {
                ILOsView()
            }
            .tabItem {
                Label("ILOs", systemImage: "doc")
            }
            .tag(Tab.ilo)
        }
    }
}

// MARK: - Tab

extension TabNavigation {
    enum Tab {
        case all
        case lessonTypes
        case ilo
    }
}

struct TabNavigation_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigation()
    }
}
