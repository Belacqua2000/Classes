//
//  TabNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 08/09/2020.
//

import SwiftUI

struct TabNavigation: View {
    @State private var selection: Tab = .all
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil))
            }
            .tabItem {
                Label("All Classes", systemImage: "books.vertical")
            }
            .tag(Tab.all)
            
            NavigationView {
                List {
                    ForEach(Lesson.LessonType.allCases) { lesson in
                        NavigationLink(
                            destination: LessonsView(filter: LessonsView.Filter(filterType: .lessonType, lessonType: lesson)),
                            label: {
                                Label(lesson.rawValue, systemImage: Lesson.lessonIcon(type: lesson.rawValue))
                            })
                    }
                }
                .navigationTitle("Lesson Types")
            }
            .tabItem {
                Label("Class Types", systemImage: "list.bullet")
            }
            .tag(Tab.all)
        }
    }
}

// MARK: - Tab

extension TabNavigation {
    enum Tab {
        case all
        case favorites
        case rewards
        case recipes
    }
}

struct TabNavigation_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigation()
    }
}
