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
    @State private var isDeleteAlertShown: Bool = false
    @State private var isInValidURLAlertShown: Bool = false
    @State private var isEditingLesson: Bool = false
    @State private var isAddingResource: Bool = false
    @State private var isAddingILO: Bool = false
    @State private var editILOViewState: EditILOView.AddOutcomeViewState = .single
    @State private var tagPopoverPresented: Bool = false
    
    //MARK: - Scene Storage
    @SceneStorage("iloSectionExpanded") var iloSectionExpanded = true
    @SceneStorage("resourceSectionExpanded") var resourceSectionExpanded = false
    
    //MARK: - Model
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
    
    
    //MARK: - ILOs
    @State var iloListSelection: Set<ILO> = []
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
    @State var resourceListSelection = Set<Resource>()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Resource.name, ascending: true)],
        animation: .default)
    private var resources: FetchedResults<Resource>
    /*private var resources: [Resource] {
     return lesson.resource?.allObjects as? [Resource] ?? []
     }*/
    @State private var selectedResource: Resource? = nil
    
    
    //MARK: - Views
    var toggleWatchedButton: some View {
        Button(action: {
               withAnimation {
                    lesson.toggleWatched(context: managedObjectContext)
                }
        }, label: {
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
                        if lesson.notes != "" && lesson.notes != nil {
                            Label("Notes", systemImage: "text.justifyleft")
                                .font(.headline)
                            Text(lesson.notes ?? "")
                                .multilineTextAlignment(.leading)
                                .padding(.bottom)
                        }
                        if filteredILOs.count != 0 {
                            ILOsProgressView(completedILOs: completedILOs)
                        }
                        
                        DisclosureGroup(isExpanded: $iloSectionExpanded, content: {
                            ILOSection(lesson: lesson, isAddingILO: $isAddingILO, editILOViewState: $editILOViewState)
                        }, label: {
                            Label("Learning Outcomes", systemImage: "list.number")
                                .font(.headline)
                        })
                        
                        DisclosureGroup(isExpanded: $resourceSectionExpanded, content: {
                            ResourceSection(isAddingResource: $isAddingResource, lesson: lesson, resources: resources)
                        }, label: {
                            Label("Resources", systemImage: "globe")
                                .font(.headline)
                        })
                        
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
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu(content: {
                        AddILOMenu(editILOViewState: $editILOViewState, isAddingILO: $isAddingILO)
                        AddResourceButton(isAddingResource: $isAddingResource)
                    }, label: {
                        Label("Add Items", systemImage: "text.badge.plus")
                    })
                    .labelStyle(DefaultLabelStyle())
                    .help("Add learning outcomes and resources")
                    
                    Button(action: {
                        tagPopoverPresented = true
                    }, label: {
                        Label("Edit Tags", systemImage: "tag")
                    })
                    .help("Edit the tags for this lesson")
                    .popover(isPresented: $tagPopoverPresented) {
                        /*AllocateTagView(selectedTags: $lesson.tag.allObjects as? [Tag])*/
                    }
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
            .alert(isPresented: $isDeleteAlertShown) {
                Alert(title: Text("Delete Lesson"), message: Text("Are you sure you want to delete?  This action cannot be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLesson), secondaryButton: .cancel(Text("Cancel"), action: {isDeleteAlertShown = false}))
            }
            .background(Color("SecondaryColor-1").edgesIgnoringSafeArea([.bottom, .horizontal]))
    }
    
    func createILO(index: Int) {
        ILO.create(in: managedObjectContext, title: newILOText, index: index, lesson: lesson)
        newILOText = ""
    }
    
    func deleteLesson() {
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
