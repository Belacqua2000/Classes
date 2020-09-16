//
//  ILOsView.swift
//  Classes
//
//  Created by Nick Baughan on 08/09/2020.
//

import SwiftUI

struct ILOsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.lesson?.date, ascending: true)],
        animation: .default)
    private var ilos: FetchedResults<ILO>
    var body: some View {
        if ilos.count > 0 {
            List(ilos) { ilo in
                Text(ilo.title!)
                    .navigationTitle("All ILOs")
            }
            .listStyle(InsetListStyle())
        } else {
            Text("No ILOs")
                .navigationTitle("All ILOs")
        }
        //.navigationSubtitle("\(ilos.count) ILOs")
    }
}

struct ILOsView_Previews: PreviewProvider {
    static var previews: some View {
        ILOsView()
    }
}
