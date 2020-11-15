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
            Button(action: {
                detailStates.editILOViewState = .single
                detailStates.addILOPresented = true
            }, label: {
                Text("Add Single Outcome")
            })
            
            Button(action: {
                detailStates.editILOViewState = .multiple
                detailStates.addILOPresented = true
            }, label: {
                Text("Batch Add Outcomes")
            })
        }, label: {
            Label("Add Learning Outcomes", systemImage: "text.badge.plus")
        })
        .help("Add learning outcomes to this lesson")
    }
}

struct AddILOMenu_Previews: PreviewProvider {
    static var previews: some View {
        AddILOMenu(detailStates: DetailViewStates())
    }
}
