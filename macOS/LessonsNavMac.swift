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
    
    let nc = NotificationCenter.default
    @Binding var selectedLesson: Set<Lesson>
    @Binding var filter: LessonsFilter
    
    var body: some View {
        GeometryReader { gr in
            HSplitView {
                LessonsListContent(selection: $selectedLesson, filter: $filter)
                    //.fileMover(isPresented: $shareSheetShown, file: Lesson.export(lessons: Array(selectedLesson)), onCompletion: {_ in })
                    
                if selectedLesson.count == 1 {
                    DetailView(lesson: selectedLesson.first!)
                        .frame(minWidth: gr.size.width * 0.3, idealWidth: gr.size.width / 2, maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text(selectedLesson.isEmpty ? "Select a lesson" : "\(selectedLesson.count) lessons selected")
                        .frame(minWidth: gr.size.width * 0.3, idealWidth: gr.size.width / 2, maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .sheet(item: $viewStates.lessonToChange, onDismiss: {
                viewStates.lessonToChange = nil
            }) { value in
                AddLessonView(lesson: value, isPresented: .constant(false))
            }
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    ToggleWatchedButton(lessons: Array(selectedLesson))
                    
                    DeleteLessonButton()
                        .disabled(selectedLesson.isEmpty)
                    
                    Spacer()
                }
                
                ToolbarItemGroup(placement: .automatic) {
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
                    
                    EditLessonButton(lessons: Array(selectedLesson))
                    Spacer()
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addLesson, label: {
                        Label("Add Lesson", systemImage: "plus")
                    })
                    .onReceive(nc.publisher(for: .newLesson), perform: { _ in
                        addLesson()
                    })
                    .help("Add a New Lesson")
                }
            }
        }
    }
    func addLesson() {
        viewStates.addLessonIsPresented = true
    }
}

struct LessonsNavMac_Previews: PreviewProvider {
    static var previews: some View {
        LessonsNavMac(selectedLesson: .constant(Set<Lesson>()), filter: .constant(LessonsFilter(filterType: .all, lessonType: nil, tag: nil)))
    }
}
