//
//  SmartGroupsList.swift
//  Classes
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct SmartGroupsList: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var selection: SourceListItem?
    
    var todayDestination: some View {
        #if !os(watchOS)
        return LessonsView(listType: LessonsListType(filterType: .today, lessonType: nil)).environmentObject(LessonsListHelper(context: viewContext))
        #else
        return LessonsListWatch(listType: LessonsListType(filterType: .today, lessonType: nil))
        #endif
    }
    
    var unwatchedDestination: some View {
        #if !os(watchOS)
        return LessonsView(listType: LessonsListType(filterType: .unwatched, lessonType: nil)).environmentObject(LessonsListHelper(context: viewContext))
        #else
        return LessonsListWatch(listType: LessonsListType(filterType: .unwatched, lessonType: nil))
        #endif
    }
    
    var unwrittenDestination: some View {
        #if !os(watchOS)
        return LessonsView(listType: LessonsListType(filterType: .unwritten, lessonType: nil)).environmentObject(LessonsListHelper(context: viewContext))
        #else
        return LessonsListWatch(listType: LessonsListType(filterType: .unwritten, lessonType: nil))
        #endif
    }
    
    var body: some View {
        Section(header: Text("Smart Groups")) {
            NavigationLink(
                destination: todayDestination,
                tag: SourceListItem(sidebarType: .today, lessonTypes: nil, tag: nil),
                selection: $selection,
                label: {
                    Label(
                        title: {Text("Today")},
                        icon: {
                            Image(systemName: "calendar")
                        })
                })
            
            NavigationLink(
                destination: unwatchedDestination,
                tag: SourceListItem(sidebarType: .unwatched, lessonTypes: nil, tag: nil),
                selection: $selection,
                label: {
                    Label(
                        title: {Text("Unwatched")},
                        icon: {
                            Image(systemName: "eye.slash")
                        })
                })
            
            NavigationLink(
                destination: unwrittenDestination,
                tag: SourceListItem(sidebarType: .unwritten, lessonTypes: nil, tag: nil),
                selection: $selection,
                label: {
                    Label(
                        title: {Text("Unwritten")},
                        icon: {
                            Image(systemName: "pencil.slash")
                        })
                })
        }.listItemTint(.preferred(.init("SecondaryColorMidpoint")))
    }
}

//struct SmartGroupsList_Previews: PreviewProvider {
//    static var previews: some View {
//        SmartGroupsList(selection: <#Binding<SourceList.Item?>#>)
//    }
//}
