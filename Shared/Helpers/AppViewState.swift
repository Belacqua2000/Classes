//
//  AppViewState.swift
//  Classes
//
//  Created by Nick Baughan on 12/10/2020.
//

import Foundation

class AppViewState: ObservableObject {
    enum TabKind {
        case summary, all, ilo
    }
    
    #if os(macOS)
    @Published var currentView: SourceListItem? = SourceListItem(sidebarType: .all)
    #else
    @Published var currentView: SourceListItem?
    #endif
    
    @Published var detailViewShowing = false
    @Published var currentTab: TabKind? = nil
}
