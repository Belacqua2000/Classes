//
//  LessonTypeNavigationList.swift
//  Classes
//
//  Created by Nick Baughan on 11/09/2020.
//

import SwiftUI

struct LessonTypeNavigationList: View {
    @Environment(\.managedObjectContext) var viewContext
    var body: some View {
        ForEach(Lesson.LessonType.allCases) { lesson in
            NavigationLink(
                destination: LessonsView(listType: LessonsListType(filterType: .lessonType, lessonType: lesson)).environmentObject(LessonsListHelper(context: viewContext)),
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
