//
//  AddILOMenu.swift
//  Classes
//
//  Created by Nick Baughan on 27/09/2020.
//

import SwiftUI

struct AddILOMenu: View {
    @Binding var editILOViewState: EditILOView.AddOutcomeViewState
    @Binding var isAddingILO: Bool
    var body: some View {
        Menu("Add Learning Outcome") {
            Button(action: {
                editILOViewState = .single
                isAddingILO = true
            }, label: {
                Text("Add Single Outcome")
            })
            
            Button(action: {
                editILOViewState = .multiple
                isAddingILO = true
            }, label: {
                Text("Batch Add Outcomes")
            })
        }
        .help("Add learning outcomes and resources to this lesson")
    }
}

struct AddILOMenu_Previews: PreviewProvider {
    static var previews: some View {
        AddILOMenu(editILOViewState: .constant(.single), isAddingILO: .constant(false))
    }
}
