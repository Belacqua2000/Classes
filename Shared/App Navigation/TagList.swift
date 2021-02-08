//
//  TagList.swift
//  Classes
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct TagList: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))], animation: .default)
    private var tags: FetchedResults<Tag>
    
    var body: some View {
        ForEach(tags) { tag in
            NavigationLink(destination:  LessonsView(listType: LessonsListType(filterType: .tag, lessonType: nil, tag: tag)).environmentObject(LessonsListHelper(context: viewContext)), label: {
                if #available(iOS 14.3, *) {
                    Label(tag.name ?? "Untitled", systemImage: "tag")
                } else {
                    Label(
                        title: { Text(tag.name ?? "Untitled") },
                        icon: { Image(systemName: "tag")
                            .foregroundColor(tag.swiftUIColor)
                        }
                    )
                }
            })
            .tag(SourceListItem(sidebarType: .tag, lessonTypes: nil, tag: tag))
            .listItemTint(tag.swiftUIColor)
        }
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        TagList()
    }
}
