//
//  VersionDetails.swift
//  Classes
//
//  Created by Nick Baughan on 05/02/2021.
//

import SwiftUI

struct VersionDetails: View {
    
    private let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    private let versionNumber: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        Text("Version Number: \(versionNumber)")
        Text("Build Number: \(buildNumber)")
    }
}

struct VersionDetails_Previews: PreviewProvider {
    static var previews: some View {
        VersionDetails()
    }
}
