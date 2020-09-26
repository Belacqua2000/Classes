//
//  ContentView.swift
//  Shared
//
//  Created by Nick Baughan on 05/09/2020.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let environmentHelpers = EnvironmentHelpers()
    @AppStorage("firstLaunch") var firstLaunch = true
    @State var sheetPresented = false
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        #if os(iOS)
        Group {
        if horizontalSizeClass == .compact {
            TabNavigation().environmentObject(environmentHelpers)
        } else {
            SidebarNavigation().environmentObject(environmentHelpers)
        }
        }
        .sheet(isPresented: $firstLaunch) {
            OnboardingView(isPresented: $firstLaunch)
        }
        #else
        SidebarNavigation()
            .frame(minWidth: 500, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
