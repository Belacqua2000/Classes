//
//  LessonsListFilter.swift
//  Classes
//
//  Created by Nick Baughan on 15/11/2020.
//

import Foundation

class LessonsListFilter: ObservableObject {
    
    @Published var watchedOnly = false
    @Published var unwatchedOnly = false
    
    @Published var iloFilterPresented = false
    
    @Published var includedLessonTypesActive = false
    @Published var includedLessonTypes = [Lesson.LessonType]()
    
    @Published var excludedLessonTypesActive = false
    @Published var excludedLessonTypes = [Lesson.LessonType]()
    
    @Published var includedTagsActive = false
    @Published var includedTags = [Tag]()
    
    @Published var excludedTagsActive = false
    @Published var excludedTags = [Tag]()
}
