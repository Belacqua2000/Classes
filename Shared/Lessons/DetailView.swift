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
    
    //View States
    @State var isEditing: Bool = false
    @State var isAdding: Bool = false
    @State var isDeleteAlertShown: Bool = false
    
    @SceneStorage("iloSectionExpanded") var iloSectionExpanded = true
    @SceneStorage("resourceSectionExpanded") var resourceSectionExpanded = false
    
    @ObservedObject var lesson: Lesson
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
    var filteredResources: [Resource] {
        return resources.filter { $0.lesson == lesson }
    }
    
    var body: some View {
        Group {
            //if lesson.id != nil {
            ScrollView(.vertical) {
                HStack {
                    VStack(alignment: .leading) {
                        LessonDetails(lesson: lesson)
                        if filteredILOs.count != 0 {
                            HStack {
                                Text("\(numberFormatter.string(from: NSNumber(value: completedILOs))!) of ILOs written")
                                ProgressView(value: completedILOs)
                                    .progressViewStyle(LinearProgressViewStyle())
                            }
                        }
                        DisclosureGroup("ILOs", isExpanded: $iloSectionExpanded) {
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
                                            Button(action: {isEditing = true}, label: {
                                                Label("Edit", systemImage: "square.and.pencil")
                                            })
                                        }))
                                    }
                                }
                                .onDelete(perform: deleteItems)
                                .onMove(perform: move)
                            }
                            .cornerRadius(10)
                            .frame(height: 200)
                            .sheet(isPresented: $isEditing, content: {
                                #if !os(macOS)
                                NavigationView {
                                    EditView(iloText: iloListSelection.first?.title ?? "", isPresented: $isEditing, ilo: iloListSelection.first, lesson: lesson)
                                }
                                #else
                                EditView(iloText: listSelection.first?.title ?? "No Title", isPresented: $isEditing, ilo: listSelection.first, lesson: lesson)
                                #endif
                            })
                            Button(action: {isAdding = true}, label: {
                                Text("Add ILO")
                            })
                            .padding(.vertical)
                            .sheet(isPresented: $isAdding, content: {
                                #if !os(macOS)
                                NavigationView {
                                    EditView(isPresented: $isAdding, lesson: lesson)
                                }
                                .navigationViewStyle(StackNavigationViewStyle())
                                #else
                                EditView(isPresented: $isAdding, lesson: lesson)
                                #endif
                            })
                        }
                        }
                        DisclosureGroup("Resources", isExpanded: $resourceSectionExpanded) {
                            List {
                                ForEach(filteredResources) { resource in
                                        HStack {
                                            Text(resource.name!)
                                            Text(resource.url)
                                        }
                                }
                            }
                            .cornerRadius(10)
                            .frame(height: 200)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    #if os(macOS)
                    Spacer()
                    #endif
                    Button(action: {lesson.toggleWatched(context: managedObjectContext)}, label: {
                        !(lesson.watched) ?
                            Label("Mark as Watched", systemImage: "checkmark.circle") : Label("Mark as Unwatched", systemImage: "checkmark.circle.fill")
                    })
                    Button(action: {
                        isDeleteAlertShown = true
                    }, label: {
                        Label("Delete Lesson", systemImage: "trash")
                    })
                    .alert(isPresented: $isDeleteAlertShown) {
                        Alert(title: Text("Delete Lesson"), message: Text("Are you sure you want to delete?  This action cannot be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLesson), secondaryButton: .cancel(Text("Cancel"), action: {isDeleteAlertShown = false}))
                    }
                }
            }
            /*} else {
             Text("Select a lesson")
             }*/
        }
        .background(Color("SecondaryColor"))
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
    
    func createILO(index: Int) {
        ILO.create(in: managedObjectContext, title: newILOText, index: index, lesson: lesson)
        newILOText = ""
    }
    
    func deleteLesson() {
        lesson.delete(context: managedObjectContext)
    }
    
    func toggleILOWritten(ilo: ILO) {
        ilo.toggleWritten(context: managedObjectContext)
    }
    
    func generateEditILOs() -> [EditILOView.editILO] {
        var editILOs: [EditILOView.editILO] = []
        for ilo in ilos {
            let editILO: EditILOView.editILO = EditILOView.editILO(id: ilo.id!, text: ilo.title!, index: Int(ilo.index))
            editILOs.append(editILO)
        }
        return editILOs
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        /*
         let source = source.first!
         if source < destination {
         var startIndex = source + 1
         let endIndex = destination - 1
         var startOrder = ilo[source].index
         while startIndex <= endIndex {
         ilo[startIndex].index = startOrder
         startOrder = startOrder + 1
         startIndex = startIndex + 1
         }
         ilo[source].index = startOrder
         
         } else if destination < source {
         var startIndex = destination
         let endIndex = source - 1
         var startOrder = ilo[destination].index + 1
         let newOrder = ilo[destination].index
         while startIndex <= endIndex {
         ilo[startIndex].index = startOrder
         startOrder = startOrder + 1
         startIndex = startIndex + 1
         }
         ilo[source].index = newOrder
         }*/
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
                let ilo = ilo as ILO
                ilo.delete(context: managedObjectContext, save: false)
            }
        }
        //lesson.updateILOIndices(in: managedObjectContext)
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredILOs[$0] }.forEach { ilo in
                managedObjectContext.delete(ilo)
            }
        }
        
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
    var lesson: Lesson
    var body: some View {
        Text(lesson.title ?? "No Title")
            .font(.title)
            .bold()
            .fixedSize(horizontal: false, vertical: true)
        #if !os(macOS)
        Text(itemFormatter.string(from: lesson.date ?? Date(timeIntervalSince1970: 0)))
            .font(.title2)
            .bold()
            .navigationTitle("\(lesson.type ?? "Class") Details")
            .navigationBarTitleDisplayMode(.inline)
        #else
        Text(itemFormatter.string(from: lesson.date ?? Date(timeIntervalSince1970: 0)))
            .font(.title2)
            .bold()
        #endif
        Text(lesson.location ?? "No Location")
            .font(.title3)
            .italic()
            .padding(.bottom)
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
