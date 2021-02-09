//
//  WatchNavigation.swift
//  ClassesWatchApp Extension
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct WatchNavigation: View {
    var body: some View {
        NavigationView {
            SourceListWatch()
//            LessonsListWatch(listType: .init(filterType: .today))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WatchNavigation_Previews: PreviewProvider {
    static var previews: some View {
        WatchNavigation()
    }
}
