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
    @State var importPresented = false
    @State var url: URL?
    
    #if !os(macOS)
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
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
        .sheet(isPresented: $importPresented) {
            ImportView(isPresented: $importPresented, url: $url)
        }
        .onOpenURL { url in
            self.url = url
            importPresented = true
        }        #else
        SidebarNavigation()
            .frame(minWidth: 500, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
            .sheet(isPresented: $firstLaunch) {
                OnboardingView(isPresented: $firstLaunch)
                    .frame(idealWidth: 600, idealHeight: 500)
            }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
