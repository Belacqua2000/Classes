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
    
    @Published var detailViewShowing = false
    @Published var currentTab: TabKind? = nil
}
