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
                /*.onDrop(of: ["public.text"], isTargeted: $tagDropTargetted, perform: { providers in
                 dropTag(providers: providers, tag: Tag(context: viewContext))
                 })*/
                .tag(SourceList.Item(sidebarType: .lessonType, lessonTypes: lesson))
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        LessonTypeList()
    }
}
