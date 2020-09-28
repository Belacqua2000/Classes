//
//  AddResourceButton.swift
//  Classes
//
//  Created by Nick Baughan on 26/09/2020.
//

import SwiftUI

struct AddResourceButton: View {
    @Binding var isAddingResource: Bool
    var body: some View {
        Button("Add Resource", action: {isAddingResource = true})
            .help("Add a resource to the lesson.")
    }
}

struct AddResourceButton_Previews: PreviewProvider {
    static var previews: some View {
        AddResourceButton(isAddingResource: .constant(false))
    }
}
