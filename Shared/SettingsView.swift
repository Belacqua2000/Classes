//
//  SettingsView.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct SettingsView: View {
    let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    let versionNumber: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    @Binding var viewIsShown: Bool
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    var body: some View {
        Form {
            
            Section(header: Text("Contact")) {
                Link(destination: URL(string: "https://nickbaughanapps.wordpress.com")!) {
                    Label("Website", systemImage: "globe")
                }
                
                Link(destination: URL(string: "mailto:nickbaughanapps@gmail.com")!) {
                    Label("Email", systemImage: "envelope")
                }
                
                Link(destination: URL(string: "https://apps.apple.com/us/app/id1532027293")!) {
                    Label("Rate and Review", systemImage: "app.badge")
                }
                
            }
            
            Section(header: Text("App Information")) {
                Label("Version Number: \(versionNumber)", systemImage: "curlybraces")
                Label("Build Number: \(buildNumber)", systemImage: "hammer")
            }
            .foregroundColor(.gray)
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: {viewIsShown = false})
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(viewIsShown: .constant(true))
        }
    }
}
