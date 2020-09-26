//
//  LessonsFilter.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import Foundation

struct LessonsFilter: Hashable {
    enum FilterTypes {
        case all, tag, lessonType, watched
    }
    var filterType: FilterTypes
    var lessonType: Lesson.LessonType?
    var tag: Tag?
}
