//
//  CollectionList.swift
//  Classes
//
//  Created by Nick Baughan on 03/03/2021.
//

import SwiftUI

struct CollectionList: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))], animation: .default)
    var tags: FetchedResults<Tag>
    
    var body: some View {
        List {
            DisclosureGroup(content: {
                
                DisclosureGroup(content: {
                    ForEach(tags) { tag in
                        NavigationLink(
                            destination: ExamView3(tag: tag),
                            label: {
                                Label(tag.name!, systemImage: "tag")
                            })
                            .listItemTint(tag.swiftUIColor)
                    }
                },
                label: {
                    Label("Tags", systemImage: "tag.circle.fill")
                })
                
                
            }, label: {
                Label(
                    title: {
                        VStack(alignment: .leading) {
                            Text("Medicine Year 3")
                                .bold()
                            
                            Text("20 Topics")
                                .font(.system(.body, design: .rounded))
                        }
                    },
                    icon: {
                        Image(systemName: "studentdesk")
                    }
                )})
            
            
            Button(action: {}, label: {
                Label("Add Collection", systemImage: "plus")
            })
        }
        .navigationTitle("Topic Collections")
        .listStyle(SidebarListStyle())
    }
}

struct CollectionList_Previews: PreviewProvider {
    static var previews: some View {
        CollectionList()
    }
}
