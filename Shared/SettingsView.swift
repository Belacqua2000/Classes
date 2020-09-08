//
//  SettingsView.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Toggle(isOn: /*@START_MENU_TOKEN@*/.constant(true)/*@END_MENU_TOKEN@*/, label: {
            Text("This is a label for a toggle")
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
