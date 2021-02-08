//
//  AllLessonsListItem.swift
//  ClassesWatchApp Extension
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct AllLessonsListItem: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var selection: SourceListItem?
    
    var destination: some View {
        #if !os(watchOS)
        return LessonsView(listType: LessonsListType(filterType: .all, lessonType: nil)).environmentObject(LessonsListHelper(context: viewContext))
        #else
        return LessonsListWatch(listType: LessonsListType(filterType: .all, lessonType: nil))
        #endif
    }
    
    var body: some View {
        NavigationLink(
            destination: destination,
            tag: SourceListItem(sidebarType: .all),
            selection: $selection,
            label: {
                Label(
                    title: {Text("All Lessons")},
                    icon: {
                        Image(systemName: "books.vertical")
                    })
            })
    }
}
