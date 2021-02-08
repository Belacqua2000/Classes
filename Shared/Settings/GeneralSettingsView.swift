//
//  GeneralSettingsView.swift
//  Classes
//
//  Created by Nick Baughan on 03/10/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct GeneralSettingsView: View {
    @AppStorage("currentLessonSort") private var sort: LessonsListContent.Sort = .dateAscending
    @State var importSheetIsShown = false
    
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
            .pickerStyle(DefaultPickerStyle())
        #else
        Form {
            picker
            Divider()
            Section {
                VersionDetails()
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
