//
//  TabNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 08/09/2020.
//

import SwiftUI

struct TabNavigation: View {
    @State private var selection: Tab = .all
    @State private var addTagShowing = false
    @State private var deleteAlertShown = false
    @State private var settingsShown = false
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>
    
    @State private var selectedTag: Tag?
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                SummaryView()
            }
            .tabItem {
                Label("Summary", systemImage: "chart.pie.fill")
            }
            .tag(Tab.summary)
            
            NavigationView {
                LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil))
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("All Lessons", systemImage: "books.vertical.fill")
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
                                    LessonsView(filter: LessonsView.Filter(filterType: .tag, lessonType: nil, tag: tag)),
                                label: {
                                    Label(title: { Text(tag.name ?? "Untitled") },
                                        icon: {
                                            Image(systemName: "tag")
                                                //.foregroundColor(tag.swiftUIColor)
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
                        .sheet(isPresented: $addTagShowing, onDismiss: {
                            selectedTag = nil
                        },content: {
                            AddTagView(isPresented: $addTagShowing, tag: $selectedTag).environment(\.managedObjectContext, viewContext)
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
                                SettingsView(viewIsShown: $settingsShown)
                            }
                        }
                    }
                    #endif
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Browse", systemImage: "list.bullet")
            }
            .tag(Tab.lessonTypes)
            
            NavigationView {
                ILOsView()
            }
            .tabItem {
                Label("Learning Outcomes", systemImage: "doc.fill")
            }
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
