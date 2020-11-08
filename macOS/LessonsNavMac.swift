//
//  Lessons.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct LessonsNavMac: View {
    @EnvironmentObject var viewStates: LessonsStateObject
    @Environment(\.managedObjectContext) var viewContext
    
    let nc = NotificationCenter.default
    @Binding var selectedLesson: Set<Lesson>
    @Binding var filter: LessonsFilter
    
    var body: some View {
        GeometryReader { gr in
            HSplitView {
                LessonsListContent(selection: $selectedLesson, filter: $filter)
                    .frame(minWidth: gr.size.width * 0.3, idealWidth: gr.size.width * 0.3)
                    .onDeleteCommand(perform: {
                        viewStates.deleteAlertShown = true
                    })
                VStack {
                if selectedLesson.count == 1 {
                    DetailView(lesson: selectedLesson.first!)
                } else {
                    ZStack {
                        BlurVisualEffectViewMac(material: .underWindowBackground, blendMode: .behindWindow)
                    Text(selectedLesson.isEmpty ? "Select a lesson" : "\(selectedLesson.count) lessons selected")
                    }
                }
                }
                .frame(minWidth: gr.size.width * 0.3, idealWidth: gr.size.width * 0.6, maxWidth: .infinity, maxHeight: .infinity)
            }
            .alert(isPresented: $viewStates.deleteAlertShown) {
                Alert(title: Text(selectedLesson.count == 1 ? "Delete Lesson" : "Delete Lessons"), message: Text("Are you sure you want to delete?  This action cannt be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLessons), secondaryButton: .cancel(Text("Cancel"), action: {viewStates.deleteAlertShown = false; viewStates.lessonToChange = nil}))
            }
            .sheet(item: $viewStates.lessonToChange, onDismiss: {
                viewStates.lessonToChange = nil
            }) { value in
                AddLessonView(lesson: value, isPresented: .constant(false))
            }
            .sheet(isPresented: $viewStates.addLessonIsPresented,
                   onDismiss: {
                    viewStates.lessonToChange = nil
                   }, content: {
                    AddLessonView(lesson: viewStates.lessonToChange, isPresented: $viewStates.addLessonIsPresented, type: filter.lessonType ?? .lecture).environment(\.managedObjectContext, viewContext)
                   })
            .toolbar(id: "MacMainToolbar") {
                ToolbarItem(id: "ScrollToolbarButton", placement: .automatic) {
                    Button(action: {
                        nc.post(Notification(name: .scrollToNow))
                    }, label: {
                        Label("Scroll To Now", systemImage: "calendar.badge.clock")
                    })
                    .help("Scroll to the next lesson in the list after now.")
                }
                
                ToolbarItem(id: "ToggleWatchedToolbarButton", placement: .automatic) {
                    ToggleWatchedButton(lessons: Array(selectedLesson))
                }
                
                ToolbarItem(id: "DeleteLessonToolbarButton", placement: .automatic) {
                    DeleteLessonButton().environmentObject(viewStates)
                    .disabled(selectedLesson.isEmpty)
                }
                
                ToolbarItem(id: "TagToolbarButton", placement: .automatic) {
                    Button(action: {
                        viewStates.tagPopoverPresented = true
                    }, label: {
                        Label("Edit Tags", systemImage: "tag")
                    })
                    .disabled(selectedLesson.count != 1)
                    .help("Edit the tags for this lesson")
                    .popover(isPresented: $viewStates.tagPopoverPresented) {
                        AllocateTagView(selectedTags:
                                            Binding(
                                                get: {selectedLesson.first!.tag!.allObjects as! [Tag]},
                                                set: {
                                                    for tag in selectedLesson.first!.tag!.allObjects as! [Tag] {
                                                        (selectedLesson.first!).removeFromTag(tag)
                                                    }
                                                    for tag in $0 {
                                                        selectedLesson.first!.addToTag(tag)
                                                    }
                                                })
                        )
                        .frame(width: 200, height: 150)
                    }
                }
                
                ToolbarItem(id: "AddILOResourceToolbarMenu", placement: .automatic) {
                    Menu(content: {
                        AddILOMenu(editILOViewState: $viewStates.editILOViewState, isAddingILO: $viewStates.addILOPresented)
                            .disabled(selectedLesson.count != 1)
                        AddResourceButton(isAddingResource: $viewStates.addResourcePresented)
                            .disabled(selectedLesson.count != 1)
                    }, label: {
                        Label("Add Items", systemImage: "text.badge.plus")
                    })
                    .labelStyle(DefaultLabelStyle())
                    .help("Add learning outcomes and resources")
                }
                
                ToolbarItem(id: "EditLessonToolbarButton", placement: .automatic) {
                    EditLessonButton(lessons: Array(selectedLesson))
                }
                
                ToolbarItem(id: "AddLessonToolbarButton", placement: .primaryAction) {
                    Button(action: addLesson, label: {
                        Label("Add Lesson", systemImage: "plus")
                    })
                    .onReceive(nc.publisher(for: .newLesson), perform: { _ in
                        addLesson()
                    })
                    .help("Add a New Lesson")
                }
            }
            .onReceive(nc.publisher(for: .tagAllocateViewShown), perform: { _ in
                viewStates.tagPopoverPresented = true
            })
        }
        .fileExporter(
            isPresented: $viewStates.exporterShown,
            document: LessonJSON(lessons: Array(selectedLesson)),
            contentType: .classesFormat,
            onCompletion: {_ in 
                
            })
    }
    
    func addLesson() {
        viewStates.addLessonIsPresented = true
    }
    
    private func deleteLessons() {
        withAnimation {
            viewStates.lessonToChange?.delete(context: viewContext)
            for lesson in selectedLesson {
                lesson.delete(context: viewContext)
            }
        }
        viewStates.lessonToChange = nil
        selectedLesson.removeAll()
    }
}

struct LessonsNavMac_Previews: PreviewProvider {
    static var previews: some View {
        LessonsNavMac(selectedLesson: .constant(Set<Lesson>()), filter: .constant(LessonsFilter(filterType: .all, lessonType: nil, tag: nil)))
    }
}
