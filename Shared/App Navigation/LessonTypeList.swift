//
//  LessonTypeList.swift
//  Classes
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct LessonTypeList: View {
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        Section(header: Text("Lesson Type")) {
            
            #if !os(watchOS)
            ForEach(Lesson.LessonType.allCases) { lesson in
                NavigationLink(destination: LessonsView(listType: LessonsListType(filterType: .lessonType, lessonType: lesson)).environmentObject(LessonsListHelper(context: viewContext))) {
                    Label(
                        title: {
                            Text(Lesson.lessonTypePlural(type: lesson.rawValue))
                        },
                        icon: {
                            Image(systemName: Lesson.lessonIcon(type: lesson.rawValue))
                        }
                    )
                }
                .tag(SourceListItem(sidebarType: .lessonType, lessonTypes: lesson))
            }
            #else
            ForEach(Lesson.LessonType.allCases) { lesson in
                NavigationLink(destination: LessonsListWatch(listType: LessonsListType(filterType: .lessonType, lessonType: lesson))) {
                    Label(
                        title: {
                            Text(Lesson.lessonTypePlural(type: lesson.rawValue))
                        },
                        icon: {
                            Image(systemName: Lesson.lessonIcon(type: lesson.rawValue))
                        }
                    )
                }
                .tag(SourceListItem(sidebarType: .lessonType, lessonTypes: lesson))
            }
            #endif
        }
        .listItemTint(.preferred(.accentColor))
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        LessonTypeList()
    }
}
