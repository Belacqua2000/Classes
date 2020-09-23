//
//  LessonsView.swift
//  Classes
//
//  Created by Nick Baughan on 07/09/2020.
//

import SwiftUI

struct LessonsView: View {
    struct Filter: Hashable {
        enum FilterTypes {
            case all, tag, lessonType, watched
        }
        var filterType: FilterTypes
        var lessonType: Lesson.LessonType?
        var tag: Tag?
    }
    
    @State var lessonCount: Int = 0
    
    var titleString: String {
        switch filter.filterType {
        case .all:
            return("All Lessons")
        case .tag:
            return("Tag: \(filter.tag?.name ?? "")")
        case .lessonType:
            return Lesson.lessonTypePlural(type: filter.lessonType?.rawValue)
        case .watched:
            return("Watched Lessons")
        }
    }
    
    @State var filter: Filter
    var body: some View {
        #if os(macOS)
        LessonsListContent(lessonCount: $lessonCount, filter: $filter)
            .navigationTitle(titleString)
            .navigationSubtitle("\(lessonCount) Lessons")
        #else
        LessonsListContent(lessonCount: $lessonCount, filter: $filter)
                .navigationTitle(titleString)
        #endif
    }
}

struct AllLessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil))
    }
}
