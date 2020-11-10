//
//  SidebarNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 05/09/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct SidebarNavigation: View {
    
    //Environment
    @Environment(\.managedObjectContext) var viewContext
//    @EnvironmentObject var appViewState: AppViewState
    
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
    
    @State private var tagDropTargetted = false
//    let dropDelegate = LessonDrop()
    
    // Tag Fetch Request
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)], animation: .default)
    private var tags: FetchedResults<Tag>
    
    // Lessons Fetch Request
    @FetchRequest(sortDescriptors: [])
    private var fetchedLessons: FetchedResults<Lesson>
   
    @State var selection: SidebarItem? = SidebarItem(sidebarType: .all)
    
    var sidebar: some View {
        List(selection: $selection) {
            
            NavigationLink(
                destination: SummaryView(),
                tag: SidebarItem(sidebarType: .summary),
                selection: $selection,
                label: {
                    Label(
                        title: {Text("Summary")},
                        icon: {
                            Image(systemName: "chart.pie")
                        })
                })
                .tag(SidebarItem(sidebarType: .summary))
            
            NavigationLink(
                destination: LessonsView(filter: LessonsFilter(filterType: .all, lessonType: nil)).environmentObject(LessonsStateObject()),
                tag: SidebarItem(sidebarType: .all),
                selection: $selection,
                label: {
                    Label(
                        title: {Text("All Lessons")},
                        icon: {
                            Image(systemName: "books.vertical")
                        })
                })
            
            NavigationLink(
                destination: ILOsView(),
                tag: SidebarItem(sidebarType: .ilo),
                selection: $selection,
                label: {
                    Label(
                        title: {Text("Learning Outcomes")},
                        icon: {
                            Image(systemName: "doc")
                        })
                })
            
            Section(header: Text("Class Type")) {
                ForEach(Lesson.LessonType.allCases) { lesson in
                    NavigationLink(destination: LessonsView(filter: LessonsFilter(filterType: .lessonType, lessonType: lesson)).environmentObject(LessonsStateObject())) {
                        Label(
                            title: {
                                Text(Lesson.lessonTypePlural(type: lesson.rawValue))
                            },
                            icon: {
                                Image(systemName: Lesson.lessonIcon(type: lesson.rawValue))
                            }
                        )
                    }
                    /*.onDrop(of: ["public.text"], isTargeted: $tagDropTargetted, perform: { providers in
                        dropTag(providers: providers, tag: Tag(context: viewContext))
                    })*/
                    .tag(SidebarItem(sidebarType: .lessonType, lessonTypes: lesson))
                }
            }
            
            Section(header: Text("Tags")) {
                ForEach(tags) { tag in
                    NavigationLink(destination:  LessonsView(filter: LessonsFilter(filterType: .tag, lessonType: nil, tag: tag)).environmentObject(LessonsStateObject())) {
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
                    
                    /*.onDrop(of: [UTType.text], isTargeted: $tagDropTargetted, perform: { providers in
                        dropTag(providers: providers, tag: tag)
                    })*/
                }
                .onDelete(perform: delete)
                .alert(isPresented: $deleteAlertShown) {
                    Alert(title: Text("Delete Tag"), message: Text("Are you sure you want to delete?  This action cannot be undone."), primaryButton: .destructive(Text("Delete"), action: deleteTag), secondaryButton: .cancel(Text("Cancel"), action: {deleteAlertShown = false; selectedTag = nil}))
                }
                Button(action: addTag, label: {
                    Label("Add Tag", systemImage: "plus.circle")
                })
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .listStyle(SidebarListStyle())
        .sheet(isPresented: $addTagShowing, onDismiss: {
            selectedTag = nil
        }, content: {
            AddTagView(isPresented: $addTagShowing, tag: $selectedTag).environment(\.managedObjectContext, viewContext)
        })
    }
    
    var body: some View {
        NavigationView {
            sidebar
                .onReceive(NotificationCenter.default.publisher(for: .showSummary), perform: { _ in
                    selection = SidebarItem(sidebarType: .summary)
                })
                .onReceive(NotificationCenter.default.publisher(for: .showAll), perform: { _ in
                    selection = SidebarItem(sidebarType: .all)
                })
                .onReceive(NotificationCenter.default.publisher(for: .showILOs), perform: { _ in
                    selection = SidebarItem(sidebarType: .ilo)
                })
                .navigationTitle("Classes")
                .toolbar {
                    #if !os(macOS)
                    ToolbarItem(id: "ShowSettingsButton", placement: .primaryAction) {
                        Button(action: {
                                settingsShown = true
                        }, label: {
                            Label("Settings", systemImage: "gear")
                        })
                        .keyboardShortcut(",", modifiers: .command)
                        .sheet(isPresented: $settingsShown) {
                            NavigationView {
                                SettingsViewiOS(viewIsShown: $settingsShown)
                            }
                        }
                    }
                    #endif
                }
            #if os(iOS)
            SummaryView()
            #endif
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
    
    func dropTag(providers: [NSItemProvider], tag: Tag) -> Bool {
        
        for item in providers {
            
            if item.canLoadObject(ofClass: NSString.self) {
                
                item.loadObject(ofClass: NSString.self, completionHandler: { (data, error) in
             
                    if let lesson = fetchedLessons.first(where: {($0 as Lesson).id!.uuidString as NSString == data as! NSString}) {
                        
                        lesson.addToTag(tag)
                        
                    }
                    
                })
                
            } else {
                return false
            }
        }
        
        return true
    }
    
    /*struct LessonDrop: DropDelegate {
        // Lessons Fetch Request
        @FetchRequest(sortDescriptors: [])
        private var fetchedLessons: FetchedResults<Lesson>
        
        func performDrop(info: DropInfo) -> Bool {
            let items = info.itemProviders(for: ["String"])
            
            let lessons: [Lesson] = Array(fetchedLessons)
            
            for item in items {
                if item.canLoadObject(ofClass: NSString.self) {
                item.loadObject(ofClass: NSString.self, completionHandler: { (data, error) in
                    
                    if let lesson = lessons.first(where: {($0 as Lesson).id!.uuidString as NSString == data as! NSString}) {
                        
                        
                        
                    }
                    
                })
            }
                return true
            }
            
            return false
        }
        
        
    }*/
}
