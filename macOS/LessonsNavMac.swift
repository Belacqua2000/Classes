//
//  Lessons.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct LessonsNavMac: View {
    @EnvironmentObject var viewStates: LessonsListHelper
    @Environment(\.managedObjectContext) var viewContext
    
    let nc = NotificationCenter.default
    @Binding var selectedLesson: Set<Lesson>
    @Binding var listType: LessonsListType
    
    var body: some View {
        GeometryReader { gr in
            HSplitView {
                LessonsListContent(listType: $listType)
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
                    AddLessonView(lesson: viewStates.lessonToChange, isPresented: $viewStates.addLessonIsPresented, type: listType.lessonType ?? .lecture).environment(\.managedObjectContext, viewContext)
                   })
                
            }
            .onReceive(nc.publisher(for: .tagAllocateViewShown), perform: { _ in
                viewStates.tagPopoverPresented = true
            })
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
        LessonsNavMac(selectedLesson: .constant(Set<Lesson>()), listType: .constant(LessonsListType(filterType: .all, lessonType: nil, tag: nil)))
    }
}
