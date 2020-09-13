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
    
    var titleString: String {
        switch filter.filterType {
        case .all:
            return("All Lessons")
        case .tag:
            return("Tag: \(filter.tag?.name ?? "")")
        case .lessonType:
            return("\(filter.lessonType?.rawValue ?? "Lesson")s")
        case .watched:
            return("Watched Lessons")
        }
    }
    
    @State var filter: Filter
    var body: some View {
        #if os(macOS)
        NavigationView {
            LessonsListContent(filter: $filter)
                .navigationTitle(titleString)
        }
        #else
        LessonsListContent(filter: $filter)
                .navigationTitle(titleString)
        #endif
    }
}

struct AllLessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil))
    }
}
