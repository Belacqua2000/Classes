//
//  CollectionList4.swift
//  Classes
//
//  Created by Nick Baughan on 05/03/2021.
//

import SwiftUI

struct CollectionList4: View {
    var body: some View {
        List {
            Section(header: Text("Study Tools")) {
                Label("Study Timer", systemImage: "timer")
            }
            Section(header: Text("Topics")) {
                DisclosureGroup(content: {
                    NavigationLink(destination: Version4(title: "All Topics").frame(minWidth: 200)) {
                        Label("All Topics", systemImage: "list.bullet")
                    }
                    NavigationLink(destination: Version4(title: "Phase 3")) {
                        Label("Phase 3", systemImage: "studentdesk")
                    }
                    NavigationLink(destination: Version4(title: "Phase 4")) {
                        Label("Phase 4", systemImage: "studentdesk")
                    }
                    NavigationLink(destination: Version4(title: "SSC")) {
                        Label("SSC", systemImage: "studentdesk")
                    }
                }, label: {
                    Label("Medicine", systemImage: "folder")
                })
            }
        }
        .toolbar {
            #if os(macOS)
            ToolbarItem(placement: .automatic) {
                Button(action: toggleSidebar, label: {Label("Toggle Sidebar", systemImage: "sidebar.leading")})
            }
            #endif
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Classes")
    }
    private func toggleSidebar() {
            #if os(macOS)
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
            #endif
        }
}

struct CollectionList4_Previews: PreviewProvider {
    static var previews: some View {
        CollectionList4()
    }
}
