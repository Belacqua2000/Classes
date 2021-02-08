//
//  SourceListItem.swift
//  ClassesWatchApp Extension
//
//  Created by Nick Baughan on 08/02/2021.
//

import Foundation

struct SourceListItem: Hashable {
    enum SidebarTypes {
        case summary
        case all
        case ilo
        case lessonType
        case tag
        
        case today
        case unwatched
        case unwritten
    }
    var sidebarType: SidebarTypes
    var lessonTypes: Lesson.LessonType?
    var tag: Tag?
}
