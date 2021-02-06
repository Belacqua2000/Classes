//
//  DetailView.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI
import CoreData

struct DetailView: View {
    
    //MARK: - Environment Variables
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    //MARK: - View States
    @EnvironmentObject var viewStates: LessonsListHelper
    @EnvironmentObject var appViewState: AppViewState
    @State private var isInValidURLAlertShown: Bool = false
    
    @State var tagShown = false
    
    @StateObject var detailStates = DetailViewStates()
    
    let nc = NotificationCenter.default
    
    static let userActivityType = "com.baughan.classes.detailview"
    //MARK: - Scene Storage
    @SceneStorage("iloSectionExpanded") var iloSectionExpanded = true
    @SceneStorage("resourceSectionExpanded") var resourceSectionExpanded = true
    
    //MARK: - Model
    @ObservedObject var lesson: Lesson
    @State var lessonToEdit: Lesson?
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default)
    private var unfilteredTags: FetchedResults<Tag>
    private var tags: [Tag]? {
        let tags = lesson.tag?.allObjects as? [Tag]
        return tags?.sorted {
            $0.name?.localizedStandardCompare($1.name ?? "") == .orderedAscending
        }
        
    }
    
    
    //MARK: - ILOs
    @State var iloListSelection = Set<ILO>()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.index, ascending: true), NSSortDescriptor(keyPath: \ILO.title, ascending: true)],
        animation: .default)
    private var ilos: FetchedResults<ILO>
    var filteredILOs: [ILO] {
        return ilos.filter { $0.lesson == lesson }
    }
    
    @State var newILOText: String = ""
    @State var newILOSaveButtonShown: Bool = false
    
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
    
    //MARK: - Resources
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Resource.name, ascending: true)],
        animation: .default)
    private var resources: FetchedResults<Resource>
    /*private var resources: [Resource] {
     return lesson.resource?.allObjects as? [Resource] ?? []
     }*/
    @State private var selectedResource: Resource? = nil
    
    
    //MARK: - Views
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 10) {
                LessonDetails(lesson: lesson)
                    .popover(isPresented: $tagShown) {
                        
                        AllocateTagView(selectedTags:
                                            Binding(
                                                get: {lesson.tag!.allObjects as! [Tag]},
                                                set: {
                                                    for tag in lesson.tag!.allObjects as! [Tag] {
                                                        lesson.removeFromTag(tag)
                                                    }
                                                    for tag in $0 {
                                                        lesson.addToTag(tag)
                                                    }
                                                })
                                        
                        )
                        .frame(width: 400, height: 200)
                    }
                if !(tags?.isEmpty ?? true) {
                    DetailViewTags(tags: tags)
                }
                if lesson.notes != "" && lesson.notes != nil {
                    LessonNotes(text: lesson.notes ?? "")
                }
                
                ILOSection(viewStates: detailStates, lesson: lesson)
                    .modifier(DetailBlock())
                
                ResourceSection(resources: resources, addResourcePresented: $detailStates.addResourcePresented, lesson: lesson)
                    .modifier(DetailBlock())
                
                EmptyView()
                    .sheet(isPresented: $detailStates.editLessonShown,
                           onDismiss: {
                            detailStates.lessonToChange = nil
                           }, content: {
                            AddLessonView(lesson: detailStates.lessonToChange, isPresented: $detailStates.editLessonShown).environment(\.managedObjectContext, managedObjectContext)
                           })
                    .alert(isPresented: $detailStates.deleteAlertShown) {
                        Alert(title: Text("Delete Lesson"), message: Text("Are you sure you want to delete?  This action cannt be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLesson), secondaryButton: .cancel(Text("Cancel"), action: {viewStates.deleteAlertShown = false; viewStates.lessonToChange = nil}))
                    }
                
            }
            .padding(.all)
        }
        .navigationTitle(lesson.title ?? "Untitled Lesson")
        .onDisappear(perform: {
            appViewState.detailViewShowing = false
            print("Disappeared")
            nc.post(.init(name: .detailNotShowing))
        })
        .onReceive(nc.publisher(for: .tagAllocateViewShown), perform: { _ in
            viewStates.tagPopoverPresented = true
        })
        .toolbar {
            DetailToolbar(lesson: lesson, viewStates: viewStates, detailStates: detailStates, tagShown: $tagShown)
        }
        .background(DetailBackgroundGradient())
    }
    
    private func createILO(index: Int) {
        ILO.create(in: managedObjectContext, title: newILOText, index: index, lesson: lesson)
        newILOText = ""
    }
    
    private func deleteLesson() {
        lesson.delete(context: managedObjectContext)
        presentationMode.wrappedValue.dismiss()
    }
    
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        #if !os(macOS)
        NavigationView{
            DetailView(lesson: Lesson.sampleData(context: context).first!)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        NavigationView{
            Text("Lessons View")
            DetailView(lesson: Lesson.sampleData(context: context).first!)
        }
        #endif
    }
}

struct ILOsProgressView: View {
    var completedILOs: Double
    var body: some View {
        HStack {
            Text("\(numberFormatter.string(from: NSNumber(value: completedILOs))!) of learning outcomes written")
                .fixedSize(horizontal: false, vertical: true)
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

struct DetailViewTags: View {
    var tags: [Tag]?
    var body: some View {
        VStack(alignment: .leading) {
            Label("Tags", systemImage: "tag")
                .font(.headline)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(tags ?? []) { tag in
                        TagIcon(tag: tag)
                        
                    }
                }
                .cornerRadius(20)
            }
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 3))
        }
        .modifier(DetailBlock())
    }
}
