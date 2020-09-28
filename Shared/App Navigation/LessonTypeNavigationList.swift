//
//  LessonTypeNavigationList.swift
//  Classes
//
//  Created by Nick Baughan on 11/09/2020.
//

import SwiftUI

struct LessonTypeNavigationList: View {
    var body: some View {
        ForEach(Lesson.LessonType.allCases) { lesson in
            NavigationLink(
                destination: LessonsView(filter: LessonsFilter(filterType: .lessonType, lessonType: lesson)),
                label: {
                    Label(Lesson.lessonTypePlural(type: lesson.rawValue), systemImage: Lesson.lessonIcon(type: lesson.rawValue))
                })
        }
    }
}

struct LessonTypeNavigationList_Previews: PreviewProvider {
    static var previews: some View {
        LessonTypeNavigationList()
    }
}
