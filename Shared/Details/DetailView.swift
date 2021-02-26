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
    
    //MARK: - Scene Storage
    @SceneStorage("iloSectionExpanded") var iloSectionExpanded = true
    @SceneStorage("resourceSectionExpanded") var resourceSectionExpanded = true
    
    //MARK: - Model
    @ObservedObject var lesson: Lesson
    @State var lessonToEdit: Lesson?
    private var tags: [Tag]? {
        let tags = lesson.tag?.allObjects as? [Tag]
        return tags?.sorted {
            $0.name?.localizedStandardCompare($1.name ?? "") == .orderedAscending
        }
        
    }
    
    
    //MARK: - ILOs
    @State var iloListSelection = Set<ILO>()
    var filteredILOs: [ILO] {
        return lesson.ilo?.allObjects as! [ILO]
    }
    
    @State var newILOText: String = ""
    
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
                
//                RatingView()
//                    .modifier(DetailBlock())
                
                ILOSection(viewStates: detailStates, lesson: lesson)
                    .modifier(DetailBlock())
                
                ResourceSection(addResourcePresented: $detailStates.addResourcePresented, lesson: lesson)
                    .modifier(DetailBlock())
                
                EmptyView()
                    .sheet(isPresented: $detailStates.editLessonShown,
                           onDismiss: {
                            detailStates.lessonToChange = nil
                           }, content: {
                            AddLessonView(lesson: $detailStates.lessonToChange, isPresented: $detailStates.editLessonShown).environment(\.managedObjectContext, managedObjectContext)
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
            tagShown = true
        })
        .toolbar {
            #if os(iOS)
            DetailToolbar(horizontalSizeClass: horizontalSizeClass ?? .compact, lesson: lesson, viewStates: viewStates, detailStates: detailStates, tagShown: $tagShown)
            #else
            DetailToolbar(lesson: lesson, viewStates: viewStates, detailStates: detailStates, tagShown: $tagShown)
            #endif
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
        .environmentObject(LessonsListHelper(context: context))
        #else
        NavigationView{
            Text("Lessons View")
            DetailView(lesson: Lesson.sampleData(context: context).first!)
                .environmentObject(LessonsListHelper(context: context))
        }
        #endif
    }
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
