//
//  DetailView.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI
import CoreData

struct DetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    //View States
    @State var isDeleteAlertShown: Bool = false
    @State var isInValidURLAlertShown: Bool = false
    @State var isEditingLesson: Bool = false
    
    @SceneStorage("iloSectionExpanded") var iloSectionExpanded = true
    @SceneStorage("resourceSectionExpanded") var resourceSectionExpanded = false
    
    @ObservedObject var lesson: Lesson
    @State var lessonToEdit: Lesson?
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default)
    private var unfilteredTags: FetchedResults<Tag>
    private var tags: [Tag]? {
        let tags = lesson.tag?.allObjects as? [Tag]
        return tags?.sorted(by: {
            $0.name! < $1.name!
        })
    }
    
    @State var newILOText: String = ""
    @State var newILOSaveButtonShown: Bool = false
    
    //ILOs
    @State var iloListSelection: Set<ILO> = []
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.index, ascending: true), NSSortDescriptor(keyPath: \ILO.title, ascending: true)],
        animation: .default)
    private var ilos: FetchedResults<ILO>
    var filteredILOs: [ILO] {
        return ilos.filter { $0.lesson == lesson }
    }
    
    var completedILOs: Double {
        var completedILOs: Double = 0
        let iloCount = Double(filteredILOs.count)
        for ilo in filteredILOs {
            if ilo.written {
                completedILOs += 1
            }
        }
        let value = completedILOs / iloCount
        return iloCount == 0 ? 1 : value
    }
    
    //Resources
    @State var resourceListSelection = Set<Resource>()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Resource.name, ascending: true)],
        animation: .default)
    private var resources: FetchedResults<Resource>
    /*private var resources: [Resource] {
     return lesson.resource?.allObjects as? [Resource] ?? []
     }*/
    @State private var selectedResource: Resource? = nil
    
    var toggleWatchedButton: some View {
        Button(action: {lesson.toggleWatched(context: managedObjectContext)}, label: {
            !(lesson.watched) ?
                Label("Mark as Watched", systemImage: "checkmark.circle") : Label("Mark as Unwatched", systemImage: "checkmark.circle.fill")
        })
        .help(!(lesson.watched) ? "Mark the lesson as watched" : "Mark the lesson as unwatched")
    }
    
    var deleteButton: some View {
        Button(action: {
            isDeleteAlertShown = true
        }, label: {
            Label("Delete Lesson", systemImage: "trash")
        })
        .alert(isPresented: $isDeleteAlertShown) {
            Alert(title: Text("Delete Lesson"), message: Text("Are you sure you want to delete?  This action cannot be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLesson), secondaryButton: .cancel(Text("Cancel"), action: {isDeleteAlertShown = false}))
        }
        .help("Delete the lesson")
    }
    
    var editInfoButton: some View {
        Button(action: {
            lessonToEdit = lesson
            isEditingLesson = true
        }, label: {
            Label("Edit Info", systemImage: "rectangle.and.pencil.and.ellipsis")
        })
        .help("Edit the lesson info")
    }
    
    var body: some View {
        Group {
            ScrollView(.vertical) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        LessonDetails(lesson: lesson)
                        if !(tags?.isEmpty ?? true) {
                            Label("Tags", systemImage: "tag")
                                .font(.headline)
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(tags ?? []) { tag in
                                        TagIcon(tag: tag)
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20).stroke(Color.accentColor)
                            )
                            .padding(.bottom)
                        }
                        if filteredILOs.count != 0 {
                            ILOsProgressView(completedILOs: completedILOs)
                        }
                        #if os(macOS)
                        Label("ILOs", systemImage: "list.number")
                            .font(.headline)
                        ILOSection(lesson: lesson)
                        #else
                        DisclosureGroup(isExpanded: $iloSectionExpanded, content: {
                            ILOSection(lesson: lesson)
                        }, label: {
                            Label("ILOs", systemImage: "list.number")
                                .font(.headline)
                        })
                        #endif
                        
                        #if os(macOS)
                        Label("Resources", systemImage: "globe")
                            .font(.headline)
                        ResourceSection(lesson: lesson, resources: resources)
                        #else
                        DisclosureGroup(isExpanded: $resourceSectionExpanded, content: {
                            ResourceSection(lesson: lesson, resources: resources)
                        }, label: {
                            Label("Resources", systemImage: "globe")
                                .font(.headline)
                        })
                        .navigationBarBackButtonHidden(false)
                        #endif
                        EmptyView()
                            .sheet(isPresented: $isEditingLesson, onDismiss: {
                                lessonToEdit = nil
                            }, content: {
                                AddLessonView(lesson: $lessonToEdit, isPresented: $isEditingLesson)
                                    .frame(minWidth: 200, idealWidth: 400, minHeight: 200, idealHeight: 250)
                            })
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                #if os(macOS)
                ToolbarItemGroup(placement: .automatic) {
                    Spacer()
                    deleteButton
                    toggleWatchedButton
                }
                ToolbarItem(placement: .primaryAction) {
                    editInfoButton
                }
                #else
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu(content: {
                        toggleWatchedButton
                        deleteButton
                        editInfoButton
                    }, label: {
                        Label("Edit Lesson", systemImage: "ellipsis.circle")
                    })
                }
                #endif
            }
        }
        .background(Color("SecondaryColor").edgesIgnoringSafeArea(.bottom))
    }
    
    func createILO(index: Int) {
        ILO.create(in: managedObjectContext, title: newILOText, index: index, lesson: lesson)
        newILOText = ""
    }
    
    func deleteLesson() {
        lesson.delete(context: managedObjectContext)
    }
    
    
}




struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let lesson = Lesson(context: context)
        #if !os(macOS)
        NavigationView{
            DetailView(lesson: lesson)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        NavigationView{
            Text("Lessons View")
            DetailView(lesson: lesson)
        }
        #endif
    }
}

struct LessonDetails: View {
    @ObservedObject var lesson: Lesson
    var body: some View {
        Text(lesson.title ?? "No Title")
            .font(.title)
            .bold()
            .fixedSize(horizontal: false, vertical: true)
        
        #if !os(macOS)
        Label(title: {
            Text(lesson.date ?? Date(), style: .date)
                .bold()
        }, icon: {
            Image(systemName: "calendar")
        })
        .font(.title2)
        .navigationTitle("\(lesson.type ?? "Class") Details")
        .navigationBarTitleDisplayMode(.inline)
        #else
        Label(title: {
            Text(lesson.date ?? Date(), style: .date)
                .bold()
        }, icon: {
            Image(systemName: "calendar")
        })
        .font(.title2)
        #endif
        
        Label(title: {
            Text(lesson.teacher ?? "")
        }, icon: {
            Image(systemName: "graduationcap")
        })
        .font(.title2)
        
        Label(title: {
            Text(lesson.location ?? "No Location")
                .italic()
        }, icon: {
            Image(systemName: "mappin")
        })
        .font(.title3)
    }
}

struct ILOsProgressView: View {
    var completedILOs: Double
    var body: some View {
        HStack {
            Text("\(numberFormatter.string(from: NSNumber(value: completedILOs))!) of ILOs written")
            ProgressView(value: completedILOs)
                .progressViewStyle(LinearProgressViewStyle())
        }
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
}

struct ILOSection: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var lesson: Lesson
    
    @State var isAddingILO: Bool = false
    @State private var selectedILO: ILO? = nil
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.index, ascending: true), NSSortDescriptor(keyPath: \ILO.title, ascending: true)],
        animation: .default)
    private var ilos: FetchedResults<ILO>
    var filteredILOs: [ILO] {
        return ilos.filter { $0.lesson == lesson }
    }
    
    var listHeight: CGFloat {
        #if os(macOS)
        return 100
        #else
        return 200
        #endif
    }
    
    /*var filteredILOs: [ILO] {
        //return resources.filter { $0.lesson == lesson }
        let ilos = lesson.ilo?.allObjects as? [ILO] ?? []
        return ilos.sorted(by: {
            $0.index < $1.index
        })
    }*/
    
    var body: some View {
        VStack(alignment: .leading) {
            #if !os(macOS)
            EditButton()
            #endif
            List {
                ForEach(filteredILOs) { ilo in
                    HStack {
                        Text("\(ilo.index + 1). \(ilo.title ?? "")")
                        Spacer()
                        Button(action: { toggleILOWritten(ilo: ilo) }, label: {
                            ilo.written ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "checkmark.circle")
                        })
                        .contextMenu(ContextMenu(menuItems: {
                            Button(action: {
                                selectedILO = ilo
                                isAddingILO = true
                            }, label: {
                                Label("Edit", systemImage: "square.and.pencil")
                            })
                        }))
                    }
                }
                .onDelete(perform: deleteILOs)
                .onMove(perform: moveILOs)
            }
            .cornerRadius(10)
            .frame(height: listHeight)
            Button(action: {isAddingILO = true}, label: {
                Text("Add ILO")
            }).sheet(isPresented: $isAddingILO, onDismiss: {
                selectedILO = nil
            }, content: {
                #if !os(macOS)
                NavigationView {
                    EditILOView(isPresented: $isAddingILO, ilo: $selectedILO, lesson: lesson)
                        .navigationTitle("Add ILO")
                }
                .navigationViewStyle(StackNavigationViewStyle())
                #else
                EditILOView(isPresented: $isAddingILO, lesson: lesson)
                #endif
            })
            .padding(.vertical)
        }
    }
    
    private func moveILOs(from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [ ILO ] = filteredILOs.map{ $0 }
        
        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination )
        
        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride( from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].index =
                Int16( reverseIndex )
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
    
    private func deleteILOs(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredILOs[$0] }.forEach { ilo in
                managedObjectContext.delete(ilo)
            }
        }
    }
    
    
    func toggleILOWritten(ilo: ILO) {
        withAnimation {
            ilo.toggleWritten(context: managedObjectContext)
        }
    }
}

struct ResourceSection: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var isInValidURLAlertShown: Bool = false
    @State var isAddingResource: Bool = false
    @State private var selectedResource: Resource?
    @ObservedObject var lesson: Lesson
    var resources: FetchedResults<Resource>
    
    var filteredResources: [Resource] {
        //return resources.filter { $0.lesson == lesson }
        let resources = lesson.resource?.allObjects as? [Resource] ?? []
        return resources.sorted(by: {
            $0.name ?? "" < $1.name ?? ""
        })
    }
    
    var listHeight: CGFloat {
        #if os(macOS)
        return 100
        #else
        return 200
        #endif
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            #if !os(macOS)
            EditButton()
            #endif
            List {
                ForEach(filteredResources) { resource in
                    let re = resource as Resource
                    HStack {
                        Text("\(re.name ?? "No Name"):")
                        Spacer()
                        if let url = re.url {
                            Link(url.host ?? "Open Link", destination: url)
                                .help(re.url?.absoluteString ?? "Link")
                        }
                    }
                    .contextMenu(ContextMenu(menuItems: {
                        Button(action: {
                            selectedResource = re
                            isAddingResource = true
                        }, label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        })
                    }))
                }
                .onDelete(perform: deleteResources)
                .alert(isPresented: $isInValidURLAlertShown) {
                    Alert(title: Text("Invalid URL"), message: Text("Unable to open the URL.  Please check it is correct."), dismissButton: .cancel(Text("Dismiss")))
                }
            }
            .cornerRadius(10)
            .frame(height: listHeight)
            Button(action: {isAddingResource = true}, label: {
                Text("Add Resource")
            })
            .padding(.vertical)
        }
        .sheet(isPresented: $isAddingResource, onDismiss: {
            selectedResource = nil
        },content: {
            #if !os(macOS)
            NavigationView {
                AddResource(resourceText: selectedResource?.name ?? "", resourceURL: selectedResource?.url?.absoluteString ?? "", isPresented: $isAddingResource, resource: $selectedResource, lesson: lesson)
                    .navigationTitle("Add Resource")
            }
            .navigationViewStyle(StackNavigationViewStyle())
            #else
            AddResource(resourceText: selectedResource?.name ?? "", resourceURL: selectedResource?.url?.absoluteString ?? "", isPresented: $isAddingResource, resource: selectedResource, lesson: lesson)
            #endif
        })
    }
    
    private func deleteResources(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredResources[$0] }.forEach { resource in
                let resource = resource as Resource
                resource.delete(context: managedObjectContext, save: false)
            }
        }
    }
}
