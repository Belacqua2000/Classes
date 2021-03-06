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
    
    @AppStorage("firstLaunch") var firstLaunch = true
    //    @State var sheetPresented = false
    //    @State var importPresented = false
    @State var modalViewShown = false
    @State private var importerPresented = false
    @State private var exporterPresented = false
    @State var url: URL?
    @State var lessonsToImport: LessonJSON?
    
    @State var whatsNewShown = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        #if os(iOS)
        PrimaryNavigation()
            .fullScreenCover(item: $currentModalView, onDismiss: {
                currentModalView = nil
            }, content: { item in
                switch item {
                case .importView:
                    NavigationView {
                        ImportView(url: $url, lessonsInFile: $lessonsToImport)
                    }
                case .onboardingView:
                    OnboardingView()
                case .whatsnewView:
                    WhatsNew()
                }
            })
            .onReceive(nc.publisher(for: .importLessons), perform: { _ in
                importerPresented = true
            })
            .fileImporter(isPresented: $importerPresented, allowedContentTypes: [UTType.classesFormat], onCompletion: { result in
                            do {
                                let url = try result.get()
                                self.url = url
                                                    print(url)
                                                    self.lessonsToImport = LessonJSON(url: url)
                                                    currentModalView = .importView
                                
                            } catch {
                                print(error.localizedDescription)
                            }
            })
            .onOpenURL { url in
                self.url = url
                self.lessonsToImport = LessonJSON(url: url)
                currentModalView = .importView
                modalViewShown = true
            }
            .onAppear(perform: checkWhatsNew)
        #else
        PrimaryNavigation()
            .frame(minWidth: 500, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
            .onOpenURL { url in
                self.url = url
                self.lessonsToImport = LessonJSON(url: url)
                currentModalView = .importView
                modalViewShown = true
            }
            .sheet(item: $currentModalView, onDismiss: {
                currentModalView = nil
            }, content: { item in
                switch item {
                case .importView:
                    ImportView(url: $url, lessonsInFile: $lessonsToImport)
                case .onboardingView:
                    OnboardingView()
                        .frame(idealWidth: 600, idealHeight: 500)
                case .whatsnewView:
                    WhatsNew()
                        .frame(idealWidth: 600, idealHeight: 500)
                }
            })
            .onAppear(perform: checkWhatsNew)
            .onReceive(nc.publisher(for: .showWhatsNew), perform: { _ in
                currentModalView = .whatsnewView
            })
            .onReceive(nc.publisher(for: .onboarding), perform: {_ in
                currentModalView = .onboardingView
            })
            .onReceive(nc.publisher(for: .importLessons), perform: { _ in
                importerPresented = true
            })
            .fileImporter(isPresented: $importerPresented, allowedContentTypes: [UTType.classesFormat], onCompletion: { result in
                switch result {
                case .success(let url):
                    self.url = url
                    self.lessonsToImport = LessonJSON(url: url)
                    currentModalView = .importView
                    modalViewShown = true
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        /*LessonsView(filter: .init(filterType: .all, lessonType: nil, tag: nil))
         .environmentObject(LessonsStateObject())*/
        #endif
    }
    
    private func checkWhatsNew() {
        if firstLaunch {
            // if the first launch, show onboarding.
            firstLaunch = false
            currentModalView = .onboardingView
            modalViewShown = true
            // set the last opened version to the current version, so that new users don't see the what's new screen
            AppFeatures.all.setLastOpenedVersion()
            return
        }
        let features = AppFeatures.all
        if features.unseenVersions.count > 0 {
            currentModalView = .whatsnewView
            modalViewShown = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
