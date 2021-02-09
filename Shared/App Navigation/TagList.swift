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
    
    var text: Text {
        if !tags.isEmpty {
            return Text("")
        } else {
            return Text("No tags.  Tags can be created on iPhone, iPad, and Mac.")
        }
    }
    
    var body: some View {
        Section(header: Text("Tags")) {
            if !tags.isEmpty {
            ForEach(tags) { tag in
                #if !os(watchOS)
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
                #else
                NavigationLink(destination:  LessonsListWatch(listType: LessonsListType(filterType: .tag, lessonType: nil, tag: tag)), label: {
                    if #available(iOS 14.3, *) {
                        Label(tag.name ?? "Untitled", systemImage: "tag")
                    } else {
                        Label(
                            title: { Text(tag.name ?? "Untitled") },
                            icon: { Image(systemName: "tag")
                            }
                        )
                    }
                })
                .tag(SourceListItem(sidebarType: .tag, lessonTypes: nil, tag: tag))
                .listItemTint(tag.swiftUIColor)
                #endif
            }
            } else {
                #if os(watchOS)
                text
                #endif
            }
        }
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        TagList()
    }
}
