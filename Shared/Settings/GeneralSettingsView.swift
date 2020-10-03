//
//  GeneralSettingsView.swift
//  Classes
//
//  Created by Nick Baughan on 03/10/2020.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("currentLessonSort") private var sort: LessonsListContent.Sort = .dateDescending
    
    var body: some View {
        
        Picker(
            selection: $sort,
            label: Label("Lesson Sort Order", systemImage: "books.vertical"),
            content: {
            ForEach(LessonsListContent.Sort.allCases) { sort in
                Text(sort.rawValue).tag(sort)
            }
        })
        .padding(.horizontal)
        .pickerStyle(SegmentedPickerStyle())
        
    }
}

struct GeneralSettings_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
