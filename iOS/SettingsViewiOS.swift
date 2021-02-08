//
//  SettingsViewiOS.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsViewiOS: View {
    let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    let versionNumber: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var viewIsShown: Bool
    @State private var welcomeScreenIsShown: Bool = false
    @State private var whatsNewShown: Bool = false
    @State private var shareSheetIsShown = false
    @State private var exportSheetIsShown = false
    @State private var importSheetIsShown = false
    @State private var safariViewPresented = false
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)])
    private var lessons: FetchedResults<Lesson>
    
    
    var body: some View {
        Form {
            Section(header: Text("Customisation")) {
                GeneralSettingsView()
            }
            
            Section(header: Text("Help")) {
                Button(action: {safariViewPresented = true}, label: {
                    Label("Help", systemImage: "questionmark")
                })
                .fullScreenCover(isPresented: $safariViewPresented) {
                    SafariView(url: URL(string: "https://nickbaughanapps.wordpress.com/classes/help/")!)
                }
                Button(action: {
                    whatsNewShown = true
                }, label: {
                    Label("What's New", systemImage: "wand.and.stars")
                })
                .sheet(isPresented: $whatsNewShown) {
                    WhatsNew()
                }
                Button(action: {welcomeScreenIsShown = true}, label: {
                    Label("Tutorial", systemImage: "graduationcap")
                })
                .fullScreenCover(isPresented: $welcomeScreenIsShown) {
                    OnboardingView()
                }
            }
            
            Section(header: Text("Export"), footer: Text("Export all lessons to keep a backup, or to share with someone else. This will export all lessons, learning outcomes, resources, and their watched/written status. Tags are not exported.")) {
                Button(action: {
                    shareSheetIsShown = true
//                    Menu(content: {
//                        Button(action: {
//                            shareSheetIsShown = true
//                        }, label: {
//                            Label("Share", systemImage: "square.and.arrow.up")
//                        })
//
//                        Button(action: {
//                            exportSheetIsShown = true
//                        }, label: {
//                            Label("Save to Files", systemImage: "folder")
//                        })
                }, label: {
                    Label("Export All Lessons", systemImage: "square.and.arrow.up")
                })
                .disabled(lessons.count == 0)
                .popover(isPresented: $shareSheetIsShown) {
                    ShareSheet(isPresented: $shareSheetIsShown, activityItems: [Lesson.export(lessons: Array(lessons)) as Any])
                }
                .fileExporter(isPresented: $exportSheetIsShown, document: LessonJSON(lessons: Array(lessons)), contentType: .classesFormat, onCompletion: {_ in})
                
                /*Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        NotificationCenter.default.post(.init(name: .importLessons))
                    }
                }, label: {
                    Label("Import Lessons", systemImage: "square.and.arrow.down")
                })*/
            }
            
            Section {
                NavigationLink(
                    destination:
                        Form {
                            Section(footer: Text("Whether you love or hate this app, feedback would be greatly appreciated.  Please feel free to write a review or get in touch.")) {
                            ContactSettingsView()
                                .navigationTitle("Contact")
                                .navigationBarTitleDisplayMode(.inline)
                            }
                        }, label: {
                    Label("Contact", systemImage: "person.crop.square")
                })
            }
            
            Section(header: Text("App Information")) {
                Label("Version Number: \(versionNumber)", systemImage: "curlybraces")
                Label("Build Number: \(buildNumber)", systemImage: "hammer")
            }
            .foregroundColor(.gray)
        }
        .navigationTitle("Settings")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: {viewIsShown = false})
            }
            #endif
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsViewiOS(viewIsShown: .constant(true))
        }
    }
}
