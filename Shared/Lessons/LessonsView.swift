//
//  LessonsView.swift
//  Classes
//
//  Created by Nick Baughan on 07/09/2020.
//

import SwiftUI

struct LessonsView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) var viewContext
    
    @State var filter: LessonsFilter
    @State private var selection = Set<Lesson>()
    
    // MARK: - View States
    
    @EnvironmentObject var viewStates: LessonsStateObject
    
    @State private var lessonTags = [Tag]()
    
    var detailLesson: Lesson?
    
    let nc = NotificationCenter.default
    
    var body: some View {
        Group {
            #if os(macOS)
            LessonsNavMac(selectedLesson: $selection, filter: $filter)
            #else
            if detailLesson == nil {
                LessonsListContent(selection: $selection, filter: $filter)
            } else {
                DetailView(lesson: detailLesson!)
            }
            #endif
        }
        .sheet(isPresented: $viewStates.addLessonIsPresented,
               onDismiss: {
                viewStates.lessonToChange = nil
               }, content: {
                AddLessonView(lesson: viewStates.lessonToChange, isPresented: $viewStates.addLessonIsPresented, type: filter.lessonType ?? .lecture).environment(\.managedObjectContext, viewContext)
               })
        .alert(isPresented: $viewStates.deleteAlertShown) {
            Alert(title: Text("Delete Lesson(s)"), message: Text("Are you sure you want to delete?  This action cannt be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLessons), secondaryButton: .cancel(Text("Cancel"), action: {viewStates.deleteAlertShown = false; viewStates.lessonToChange = nil}))
        }
    }
    
    private func deleteLessons() {
        withAnimation {
            viewStates.lessonToChange?.delete(context: viewContext)
            for lesson in selection {
                lesson.delete(context: viewContext)
            }
        }
        viewStates.lessonToChange = nil
        selection.removeAll()
    }
}

struct AllLessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(filter: LessonsFilter(filterType: .all, lessonType: nil)).environmentObject(LessonsStateObject())
    }
}
