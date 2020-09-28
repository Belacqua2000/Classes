//
//  ILOsView.swift
//  Classes
//
//  Created by Nick Baughan on 08/09/2020.
//

import SwiftUI

struct ILOsView: View {
    
    private enum ViewStates: String, CaseIterable, Identifiable {
        var id: String { return rawValue }
        case list = "Browse"
        case iloRandomiser = "Outcome Randomiser"
    }
    
    @SceneStorage("currentILOView") private var currentILOView: ViewStates = .list
    
    @State private var generatorShown = false
    
    @EnvironmentObject var randomiserShown: EnvironmentHelpers
    
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.lesson?.date, ascending: true), NSSortDescriptor(keyPath: \ILO.index, ascending: true)],
        animation: .default)
    private var ilos: FetchedResults<ILO>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
        animation: .default)
    private var lessons: FetchedResults<Lesson>
    var body: some View {
        VStack {
            if ilos.count > 0 {
                #if !os(macOS)
                AllILOsList(lessons: Array(lessons), ilos: Array(ilos))
                Spacer()
                Button(action: {randomiserShown.iloRandomiserShown = true}, label: {Text("Randomise All Outcomes")})
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .padding(.bottom)
                    .fullScreenCover(isPresented: $randomiserShown.iloRandomiserShown) {
                        NavigationView {
                            ILOGeneratorView(isPresented: $generatorShown, ilos: ilos.shuffled())
                        }
                    }
                #else
                if currentILOView == .list {
                    AllILOsList(lessons: Array(lessons), ilos: Array(ilos))
                } else {
                    ILOGeneratorView(isPresented: .constant(true), ilos: ilos.shuffled())
                }
                #endif
            } else {
                Text("No Learning Outcomes.  Add outcomes from the lesson info page.")
            }
        }
        .toolbar {
            #if os(macOS)
            ToolbarItem(placement: .principal) {
                Picker("Current View", selection: $currentILOView) {
                    ForEach(ViewStates.allCases) { state in
                        Text(state.rawValue).tag(state)
                    }
                }
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
            }
            #endif
        }
        .navigationTitle("Learning Outcomes")
    }
}

//.navigationSubtitle("\(ilos.count) ILOs")

struct ILOsView_Previews: PreviewProvider {
    static var previews: some View {
        ILOsView()
    }
}
