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
    @EnvironmentObject var viewStates: LessonsStateObject
    @EnvironmentObject var appViewState: AppViewState
    @State private var isInValidURLAlertShown: Bool = false
    
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
        return tags?.sorted(by: {
            $0.name! < $1.name!
        })
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
    var body: some View {
            ScrollView(.vertical) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        LessonDetails(lesson: lesson)
                        if !(tags?.isEmpty ?? true) {
                            DetailViewTags(tags: tags)
                        }
                        if lesson.notes != "" && lesson.notes != nil {
                            DetailNotesSection(text: lesson.notes ?? "")
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
            }
            .navigationTitle(lesson.title ?? "Untitled Lesson")
            /*.onAppear(perform: {
                appViewState.detailViewShowing = true
                print("Appeared")
                nc.post(.init(name: .detailShowing))
            })*/
            .onDisappear(perform: {
                appViewState.detailViewShowing = false
                print("Disappeared")
                nc.post(.init(name: .detailNotShowing))
            })
            .onReceive(nc.publisher(for: .tagAllocateViewShown), perform: { _ in
                viewStates.tagPopoverPresented = true
            })
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    #if os(iOS)
                    if horizontalSizeClass == .compact {
                        Menu(content: {
                            ToggleWatchedButton(lessons: [lesson])
                            DeleteLessonButton(viewStates: detailStates, lesson: lesson)
                            EditLessonButton(detailStates: detailStates, lessons: [lesson])
                        }, label: {
                            Label("Edit Lesson", systemImage: "ellipsis.circle")
                        })
                        
                    } else {
                        DeleteLessonButton(viewStates: detailStates, lesson: lesson)
                        EditLessonButton(detailStates: detailStates, lessons: [lesson])
                    }
                    #endif
                }
            }
            .toolbar(id: "DetailToolbar") {
                #if os(iOS)
                ToolbarItem(id: "Spacer", placement: .automatic) {
                        
                        EmptyView()
                    
                    }
                #else
                ToolbarItem(id: "Toggle Watched Button", placement: .automatic) {
                    ToggleWatchedButton(lessons: [lesson])
                }
                ToolbarItem(id: "Spacer") {
                    Spacer()
                }
                
                ToolbarItem(id: "Tag Button", placement: .automatic) {
                    Button(action: {
                        viewStates.tagPopoverPresented = true
                    }, label: {
                        Label("Edit Tags", systemImage: "tag")
                    })
//                    .disabled(selectedLesson.count != 1)
                    .help("Edit the tags for this lesson")
                    .popover(isPresented: $viewStates.tagPopoverPresented) {
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
                        .frame(width: 200, height: 150)
                    }
                }
                
                ToolbarItem(id: "AddResourceButton", placement: .automatic) {
                    AddResourceButton(isAddingResource: $detailStates.addResourcePresented)
                }
                ToolbarItem(id: "AddILOMenu", placement: .automatic) {
                    AddILOMenu(detailStates: detailStates)
                }
                ToolbarItem(id: "DeleteButton") {
                    DeleteLessonButton(viewStates: detailStates)
                }
                ToolbarItem(id: "EditButton") {
                    EditLessonButton(detailStates: detailStates, lessons: [lesson])
                }
                #endif
            }
            .background(LinearGradient(gradient: Gradient(colors: [.init("SecondaryColorLight"), .init("SecondaryColor")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea([.bottom, .horizontal]))
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

struct DetailNotesSection: View {
    var text: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
            Label("Notes", systemImage: "text.justifyleft")
                .font(.headline)
            Text(text)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }.modifier(DetailBlock())
    }
}
