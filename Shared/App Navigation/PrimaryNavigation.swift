//
//  PrimaryNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 05/09/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct PrimaryNavigation: View {
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) var viewContext
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @EnvironmentObject var appViewState: AppViewState
    
    // MARK: - State Properties
    @State var addTagShowing: Bool = false
    @State var selectedTag: Tag?
    @State private var deleteAlertShown = false
    @State private var settingsShown = false
    
    // MARK: - Selection
//    @State var selection: SourceListItem?
    
    var sourceList: some View {
        SourceList(selection: $appViewState.currentView, addTagShowing: $addTagShowing, selectedTag: $selectedTag, deleteAlertShown: $deleteAlertShown)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Group {
                #if os(macOS)
                sourceList
                    .listStyle(SidebarListStyle())
                #else
                if horizontalSizeClass == .compact {
                    sourceList
                        .listStyle(InsetGroupedListStyle())
                } else {
                    sourceList
                        .listStyle(SidebarListStyle())
                }
                #endif
            }
                .onReceive(NotificationCenter.default.publisher(for: .showSummary), perform: { _ in
                    appViewState.currentView = SourceListItem(sidebarType: .summary)
                })
                .onReceive(NotificationCenter.default.publisher(for: .showAll), perform: { _ in
                    appViewState.currentView = SourceListItem(sidebarType: .all)
                })
                .onReceive(NotificationCenter.default.publisher(for: .showILOs), perform: { _ in
                    appViewState.currentView = SourceListItem(sidebarType: .ilo)
                })
                .navigationTitle("Classes")
                .toolbar {
                    #if !os(macOS)
                    ToolbarItem(id: "ShowSettingsButton", placement: .primaryAction) {
                        Button(action: {
                                settingsShown = true
                        }, label: {
                            Label("Settings", systemImage: "gear")
                        })
                        .keyboardShortcut(",", modifiers: .command)
                        .sheet(isPresented: $settingsShown) {
                            NavigationView {
                                SettingsViewiOS(viewIsShown: $settingsShown)
                            }
                        }
                    }
                    #endif
                }
            #if os(macOS)
            Text("List View")
            ZStack {
                BlurVisualEffectViewMac(material: .underWindowBackground, blendMode: .behindWindow)
                Text("Select a lesson")
            }.disabled(true)
            #endif
            #if os(iOS)
            LessonsView(listType: .init(filterType: .all)).environmentObject(LessonsListHelper(context: viewContext))
            Text("Select a lesson")
            #endif
        }
    }
    
    struct SidebarNavigation_Previews: PreviewProvider {
        //@State static var selection: Set<SidebarNavigation.SourceList.Item>
        static var previews: some View {
            PrimaryNavigation()
        }
    }
}
