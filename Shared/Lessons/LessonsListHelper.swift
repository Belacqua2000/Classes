//
//  LessonsStateObject.swift
//  Classes
//
//  Created by Nick Baughan on 11/10/2020.
//

import Foundation
import CoreData

class LessonsListHelper: ObservableObject {
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var context: NSManagedObjectContext
    @Published var lessonToChange: Lesson? = nil
    @Published var selection: Set<Lesson> = Set<Lesson>()
    
    @Published var deleteAlertShown: Bool = false
    @Published var addLessonIsPresented: Bool = false
    @Published var addResourcePresented: Bool = false
    @Published var addILOPresented: Bool = false
    @Published var shareSheetShown = false
    @Published var exporterShown = false
    @Published var tagPopoverPresented = false
    
    @Published var sheetPresented = false
    @Published var sheetToPresent: LessonsListContent.Sheets?
    
    @Published var statsShown = false
    @Published var addLessonShown = false
    @Published var ilosViewShown = false
    @Published var filterViewActive = false
    
    func select(_ lessons: [Lesson]) {
        selection = Set<Lesson>(lessons)
    }
    
    func deselectAll() {
        selection.removeAll()
    }
    
    func editLesson(_ lesson: Lesson) {
        lessonToChange = lesson
        sheetToPresent = .addLesson
    }
    
    private func addLesson() {
        addLessonShown = true
    }
    
    func markOutcomesWritten(_ lesson: Lesson) {
        #if os(iOS)
        selection = [lesson]
        guard let lesson = selection.first else {return}
        #endif
        lesson.markAllILOsWritten(context: context)
    }
    
    func markOutcomesUnwritten(_ lesson: Lesson) {
        #if os(iOS)
        selection = [lesson]
        guard let lesson = selection.first else {return}
        #endif
        lesson.markAllILOsUnwritten(context: context)
    }
    
    func showShareSheet(_ lesson: Lesson) {
        #if os(iOS)
        selection = [lesson]
        #endif
        shareSheetShown = true
    }
    
    func showExporter(lesson: Lesson) {
        #if os(iOS)
        selection = [lesson]
        exporterShown = true
        #else
        exporterShown = true
        #endif
    }
    
    func toggleWatched(lessons: [Lesson]) {
            lessons.forEach({$0.toggleWatched(context: context)})
    }
    
    func markWatched(lessons: [Lesson]) {
            lessons.forEach({$0.markWatched(context: context)})
    }
    
    func markUnwatched(lessons: [Lesson]) {
            lessons.forEach({$0.markUnwatched(context: context)})
    }
    
    func duplicateLesson(_ lesson: Lesson) {
        lesson.duplicate(context: context)
    }
}
