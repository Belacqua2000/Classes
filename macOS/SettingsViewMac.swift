//
//  SettingsViewMac.swift
//  Classes (macOS)
//
//  Created by Nick Baughan on 03/10/2020.
//

import SwiftUI

struct SettingsViewMac: View {
    
    private enum SettingsTab: Hashable {
        case general, contact
    }
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(SettingsTab.general)
            Form {
                ContactSettingsView()
                    .padding()
            }
                .tabItem {
                    Label("Contact", systemImage: "person.crop.square")
                }
                .tag(SettingsTab.contact)
        }
        .padding(20)
        .frame(width: 400, height: 200)
    }
}

struct SettingsViewMac_Previews: PreviewProvider {
    static var previews: some View {
        SettingsViewMac()
    }
}
