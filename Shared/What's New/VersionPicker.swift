//
//  VersionPicker.swift
//  Classes
//
//  Created by Nick Baughan on 07/02/2021.
//

import SwiftUI

struct VersionPicker: View {
    @Binding var currentSelection: WhatsNew.VersionSelection
    var body: some View {
        Picker(selection: $currentSelection,
               label:
                VStack {
                    #if os(iOS)
                HStack {
                    Text(currentSelection.string)
                    Image(systemName: "chevron.down")
                }
                .padding(5)
//                .background(Color(.systemGray5))
                .cornerRadius(5)
                    #endif
                }
        ) {
            Text("Unseen Features").tag(WhatsNew.VersionSelection(type: .unseen, versionString: nil))
            Text("All Features").tag(WhatsNew.VersionSelection(type: .all, versionString: nil))
            ForEach(AppFeatures.all.features.sorted().reversed(), id: \.self) { version in
                Text(version.versionString).tag(WhatsNew.VersionSelection(type: .version, versionString: version.versionString))
            }
        }.animation(nil)
        .pickerStyle(MenuPickerStyle())
    }
}
