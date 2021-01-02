//
//  LessonsListType.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import Foundation

struct LessonsListType: Hashable {
    enum FilterTypes {
        case all, tag, lessonType, watched, today, unwatched, unwritten
    }
    var filterType: FilterTypes
    var lessonType: Lesson.LessonType?
    var tag: Tag?
}
