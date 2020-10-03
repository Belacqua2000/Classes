//
//  SettingsViewiOS.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct SettingsViewiOS: View {
    let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    let versionNumber: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    @Binding var viewIsShown: Bool
    @State var welcomeScreenIsShown: Bool = false
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    var body: some View {
        Form {
            
            Section(header: Text("General")) {
                GeneralSettingsView()
            }
            
            Section {
                Button(action: {welcomeScreenIsShown = true}, label: {
                    Label("Welcome Page", systemImage: "face.smiling")
                })
                .sheet(isPresented: $welcomeScreenIsShown) {
                    OnboardingView(isPresented: $welcomeScreenIsShown)
                }
            }
            
            Section {
                NavigationLink(
                    destination:
                        Form {
                            Section(footer: Text("Whether you love or hate this app, feedback would be greatly appreciated.  Please feel free to write a review or get in touch.")) {
                            ContactSettingsView()
                                .navigationTitle("Contact")
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
