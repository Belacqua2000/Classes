//
//  SidebarNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 05/09/2020.
//

import SwiftUI

struct SidebarNavigation: View {
    
    enum SidebarItem {
        case all
        case lessonType
        case ilo
    }
    
    @State var selection: Set<SidebarItem> = [.all]
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                NavigationLink(
                    destination: LessonsView(predicate: "All Classes"),
                    label: {
                        Label("All Classes", systemImage: "books.vertical")
                    })
                .tag(SidebarItem.all)
                Section(header: Text("Class Type")) {
                    ForEach(Lesson.LessonType.allCases) { lesson in
                        NavigationLink(
                            destination: LessonsView(predicate: lesson.rawValue),
                            label: {
                                Label(lesson.rawValue, systemImage: Lesson.lessonIcon(type: lesson.rawValue))
                            })
                    }
                }
                Label("ILOs", systemImage: "doc")
            }
            .navigationTitle("Classes")
            .frame(minWidth: 100, idealWidth: 150, maxHeight: .infinity)
            .listStyle(SidebarListStyle())
            //LessonsView(predicate: "All Classes")
            Text("All")
            Text("Choose a Lesson")
        }
    }
}

struct SidebarNavigation_Previews: PreviewProvider {
    //@State static var selection: Set<SidebarNavigation.SidebarItem>
    static var previews: some View {
        SidebarNavigation()
    }
}
