//
//  TabNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 08/09/2020.
//

import SwiftUI

struct TabNavigation: View {
    
    @Environment(\.editMode) var editMode
    
    // MARK: - Selections
    @State private var selection: Tab = .all
    @State private var selectedTag: Tag?
    
    // MARK: - View States
    @State private var addTagShowing = false
    @State private var deleteAlertShown = false
    @State private var settingsShown = false
    
    // MARK: - Core Data
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selection) {
            SummaryTabView()
                .tag(TabNavigation.Tab.summary)
            
            AllTabView()
                .tag(TabNavigation.Tab.all)
            
            NavigationView {
                List {
                    Section(header: Text("Lesson Types")) {
                    LessonTypeNavigationList()
                    }
                    Section(header: Text("Tags")) {
                        ForEach(tags) { tag in
                            NavigationLink(
                                destination:
                                    LessonsView(filter: LessonsFilter(filterType: .tag, lessonType: nil, tag: tag)),
                                label: {
                                    Label(title: { Text(tag.name ?? "Untitled") },
                                        icon: {
                                            Image(systemName: "tag")
                                                .foregroundColor(tag.swiftUIColor)
                                        }
                                    )
                                })
                                .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                                    Button(action: { editTag(tag: tag) }, label: {
                                        Label("Edit", systemImage: "square.and.pencil")
                                    })
                                    Button(action: {deleteTagAlert(tag: tag)}, label: {
                                        Label("Delete", systemImage: "trash")
                                    })
                                }/*@END_MENU_TOKEN@*/)
                        }
                        .onDelete(perform: deleteTags)
                        Button(action: {selectedTag = nil; addTagShowing = true}, label: {
                            Label("Add Tag", systemImage: "plus.circle")
                        })
                        .alert(isPresented: $deleteAlertShown) {
                            Alert(title: Text("Delete Tag"), message: Text("Are you sure you want to delete?  This action cannot be undone."), primaryButton: .destructive(Text("Delete"), action: deleteTag), secondaryButton: .cancel(Text("Cancel"), action: {deleteAlertShown = false; selectedTag = nil}))
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Lesson Types")
                .toolbar {
                    #if !os(macOS)
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {settingsShown = true}, label: {
                            Label("Settings", systemImage: "gear")
                        })
                        .sheet(isPresented: $settingsShown) {
                            NavigationView {
                                SettingsViewiOS(viewIsShown: $settingsShown)
                            }
                        }
                    }
                    #endif
                }
                .onReceive(NotificationCenter.default.publisher(for: .showSummary), perform: { _ in
                    selection = .summary
                })
                .onReceive(NotificationCenter.default.publisher(for: .showAll), perform: { _ in
                    selection = .all
                })
                .onReceive(NotificationCenter.default.publisher(for: .showILOs), perform: { _ in
                    selection = .ilo
                })
                .sheet(isPresented: $addTagShowing, onDismiss: {
                    selectedTag = nil
                },content: {
                    AddTagView(isPresented: $addTagShowing, tag: $selectedTag).environment(\.managedObjectContext, viewContext)
                })
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Browse", systemImage: "list.bullet")
            }
            .tag(Tab.lessonTypes)
            
            ILOsTabView()
                .tag(Tab.ilo)
        }
    }
    
    private func deleteTagAlert(tag: Tag) {
        selectedTag = tag
        deleteAlertShown = true
    }
    
    private func deleteTag() {
        withAnimation {
            selectedTag?.delete(context: viewContext)
            selectedTag = nil
        }
    }
    
    func deleteTags(at offsets: IndexSet) {
        withAnimation {
            offsets.map { tags[$0] }.forEach { tag in
                deleteTagAlert(tag: tag)
            }
        }
    }
    
    private func editTag(tag: Tag) {
        selectedTag = tag
        addTagShowing = true
    }
}

// MARK: - Tab

extension TabNavigation {
    enum Tab {
        case summary
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

struct AllTabView: View {
    var body: some View {
        NavigationView {
            LessonsView(filter: LessonsFilter(filterType: .all, lessonType: nil))
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            Label("All Lessons", systemImage: "books.vertical.fill")
        }
    }
}

struct SummaryTabView: View {
    var body: some View {
        NavigationView {
            SummaryView()
        }
        .tabItem {
            Label("Summary", systemImage: "chart.pie.fill")
        }
    }
}

struct ILOsTabView: View {
    var body: some View {
        NavigationView {
            ILOsView()
        }
        .tabItem {
            Label("Learning Outcomes", systemImage: "doc.fill")
        }
    }
}
