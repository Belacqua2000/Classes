//
//  GeneralSettingsView.swift
//  Classes
//
//  Created by Nick Baughan on 03/10/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct GeneralSettingsView: View {
    @AppStorage("currentLessonSort") private var sort: LessonsListContent.Sort = .dateDescending
    @State var importSheetIsShown = false
    
    let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    let versionNumber: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var picker: some View {
        Picker(
            selection: $sort,
            label: Label("Lesson Sort Order:", systemImage: "books.vertical"),
            content: {
            ForEach(LessonsListContent.Sort.allCases) { sort in
                Text(sort.rawValue).tag(sort)
            }
        })
    }
    
    var body: some View {
        
        #if os(iOS)
        picker
            .pickerStyle(SegmentedPickerStyle())
        #else
        Form {
            picker
            Divider()
            Section {
                Text("Version Number: \(versionNumber)")
                Text("Build Number: \(buildNumber)")
            }
        }
        #endif
    }
}

struct GeneralSettings_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
