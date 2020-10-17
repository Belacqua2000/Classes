//
//  ContactSettingsView.swift
//  Classes
//
//  Created by Nick Baughan on 03/10/2020.
//

import SwiftUI

struct ContactSettingsView: View {
    var socialMediaLinks: some View {
        Group {
            Link("Twitter", destination: URL(string: "https://twitter.com/NickBaughanApps")!)
            Link("Instagram", destination: URL(string: "https://instagram.com/nickbaughanapps?igshid=oxs426ln605n")!)
        }
    }
    var body: some View {
        Link(destination: URL(string: "https://nickbaughanapps.wordpress.com")!) {
            Label("Website", systemImage: "globe")
        }
        
        Link(destination: URL(string: "mailto:nickbaughanapps@gmail.com")!) {
            Label("Email", systemImage: "envelope")
        }
        
        Link(destination: URL(string: "https://apps.apple.com/us/app/id1532027293")!) {
            Label("Rate and Review", systemImage: "app.badge")
        }
        
        #if os(iOS)
        Menu(content: {
            socialMediaLinks
        }, label: {
            Label("Social Media", systemImage: "text.bubble")
        })
        .navigationTitle("Contact")
        #else
        Divider()
        socialMediaLinks
        #endif
    }
}

struct ContactSettings_Previews: PreviewProvider {
    static var previews: some View {
        ContactSettingsView()
    }
}
