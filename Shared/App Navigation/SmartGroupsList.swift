//
//  SmartGroupsList.swift
//  Classes
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct SmartGroupsList: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var selection: SourceList.Item?
    var body: some View {
        Section(header: Text("Smart Groups")) {
            NavigationLink(
                destination: LessonsView(listType: LessonsListType(filterType: .today, lessonType: nil)).environmentObject(LessonsListHelper(context: viewContext)),
                tag: SourceList.Item(sidebarType: .today, lessonTypes: nil, tag: nil),
                selection: $selection,
                label: {
                    Label(
                        title: {Text("Today")},
                        icon: {
                            Image(systemName: "calendar")
                        })
                })
            
            NavigationLink(
                destination: LessonsView(listType: LessonsListType(filterType: .unwatched, lessonType: nil)).environmentObject(LessonsListHelper(context: viewContext)),
                tag: SourceList.Item(sidebarType: .unwatched, lessonTypes: nil, tag: nil),
                selection: $selection,
                label: {
                    Label(
                        title: {Text("Unwatched")},
                        icon: {
                            Image(systemName: "eye.slash")
                        })
                })
            
            NavigationLink(
                destination: LessonsView(listType: LessonsListType(filterType: .unwritten, lessonType: nil)).environmentObject(LessonsListHelper(context: viewContext)),
                tag: SourceList.Item(sidebarType: .unwritten, lessonTypes: nil, tag: nil),
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
