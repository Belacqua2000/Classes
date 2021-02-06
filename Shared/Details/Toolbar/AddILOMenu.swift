//
//  AddILOMenu.swift
//  Classes
//
//  Created by Nick Baughan on 27/09/2020.
//

import SwiftUI

struct AddILOMenu: View {
    @ObservedObject var detailStates: DetailViewStates
    var body: some View {
        Menu(content: {
            Button("Add Single Outcome", action: addSingleILO)
            Button("Add Multiple Outcomes", action: addMultipleILOs)
        }, label: {
            Label("Add Learning Outcomes", systemImage: "text.badge.plus")
        })
        .help("Add learning outcomes to this lesson")
    }
    
    private func addSingleILO() {
        detailStates.editILOViewState = .single
        detailStates.addILOPresented = true
    }
    
    private func addMultipleILOs() {
        detailStates.editILOViewState = .multiple
        detailStates.addILOPresented = true
    }
}

struct AddILOMenu_Previews: PreviewProvider {
    static var previews: some View {
        AddILOMenu(detailStates: DetailViewStates())
    }
}
