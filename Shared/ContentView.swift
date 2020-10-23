//
//  ContentView.swift
//  Shared
//
//  Created by Nick Baughan on 05/09/2020.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct ContentView: View {
    private enum ModalView: String, Identifiable {
        var id: String { return rawValue }
        case importView
        case whatsnewView
        case onboardingView
    }
    
    @State private var currentModalView: ModalView?
    
    let nc = NotificationCenter.default
    
    let environmentHelpers = EnvironmentHelpers()
    @AppStorage("firstLaunch") var firstLaunch = true
//    @State var sheetPresented = false
//    @State var importPresented = false
    @State var modalViewShown = false
    @State private var importerPresented = false
    @State var url: URL?
    
    @State var whatsNewShown = false
    
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
        .sheet(item: $currentModalView, onDismiss: {
            currentModalView = nil
        }, content: { item in
            switch item {
            case .importView:
                ImportView(url: $url)
            case .onboardingView:
                OnboardingView()
            case .whatsnewView:
                WhatsNew()
            }
        })
        .onOpenURL { url in
            self.url = url
            currentModalView = .importView
            modalViewShown = true
        }
        .onAppear(perform: checkWhatsNew)
        #else
        SidebarNavigation(selection: .init(sidebarType: .all, lessonTypes: nil, tag: nil))
            .frame(minWidth: 500, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
            .sheet(isPresented: $firstLaunch) {
                OnboardingView(isPresented: $firstLaunch)
                    .frame(idealWidth: 600, idealHeight: 500)
            }
            .onReceive(nc.publisher(for: .importLessons), perform: { _ in
                importerPresented = true
            })
            .fileImporter(isPresented: $importerPresented, allowedContentTypes: [UTType.classesFormat], onCompletion: { _ in
            })
        /*LessonsView(filter: .init(filterType: .all, lessonType: nil, tag: nil))
            .environmentObject(LessonsStateObject())*/
        #endif
    }
    
    private func checkWhatsNew() {
        if firstLaunch {
            firstLaunch = false
            currentModalView = .onboardingView
            modalViewShown = true
            AppFeatures.all.setLastOpenedVersion()
            return
        }
        let features = AppFeatures.all
        if features.unseenVersions.count > 0 {
            currentModalView = .whatsnewView
            modalViewShown = true
        }
    }
    /*
    @ViewBuilder
    private func sheetContent() -> some View {
        if currentModalView == .onboardingView {
            OnboardingView(isPresented: $modalViewShown)
        } else if currentModalView == .whatsnewView {
            WhatsNew(isShowing: $modalViewShown)
        } else if currentModalView == .importView {
            ImportView(isPresented: $modalViewShown, url: $url)
        }
        /*switch currentModalView {
        case .importView:
            ImportView(isPresented: $modalViewShown, url: $url)
        case .onboardingView:
            OnboardingView(isPresented: $modalViewShown)
        case .whatsnewView:
            WhatsNew(isShowing: $modalViewShown)
        case .none:
            EmptyView()
        }*/
    }*/
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
