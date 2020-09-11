//
//  SidebarNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 05/09/2020.
//

import SwiftUI

struct SidebarNavigation: View {
    
    struct SidebarItem: Hashable {
        enum SidebarTypes {
            case all
            case ilo
            case lessonType
        }
        var sidebarType: SidebarTypes
        var lessonTypes: Lesson.LessonType?
    }
    
    @State var selection = Set<SidebarItem>()
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                NavigationLink(
                    destination:
                        LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil)),
                    label: {
                        Label("All Classes", systemImage: "books.vertical")
                    })
                    .tag(SidebarItem(sidebarType: .all, lessonTypes: nil))
                
                NavigationLink(
                    destination: ILOsView(),
                    label: {
                        Label("ILOs", systemImage: "doc")
                    })
                    .tag(SidebarItem(sidebarType: .ilo, lessonTypes: nil))
                
                Section(header: Text("Class Type")) {
                    ForEach(Lesson.LessonType.allCases) { lesson in
                        NavigationLink(
                            destination:
                                LessonsView(filter: LessonsView.Filter(filterType: .lessonType, lessonType: lesson)),
                            label: {
                                Label(lesson.rawValue, systemImage: Lesson.lessonIcon(type: lesson.rawValue))
                            })
                            .tag(SidebarItem(sidebarType: .lessonType, lessonTypes: lesson))
                    }
                }
            }
            .navigationTitle("Classes")
            .frame(minWidth: 100, idealWidth: 150, maxHeight: .infinity)
            .listStyle(SidebarListStyle())
            LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil))
            if selection != [SidebarItem(sidebarType: .ilo, lessonTypes: nil)] {
                Text("Select a Class")
            }
        }
        .onAppear(perform: {
            selection = [SidebarItem(sidebarType: .all, lessonTypes: nil)]
        })
    }
}

struct SidebarNavigation_Previews: PreviewProvider {
    //@State static var selection: Set<SidebarNavigation.SidebarItem>
    static var previews: some View {
        SidebarNavigation()
    }
}
