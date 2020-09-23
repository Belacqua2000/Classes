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
        case list = "List"
        case iloRandomiser = "ILO Randomiser"
    }
    
    @SceneStorage("currentILOView") private var currentILOView: ViewStates = .list
    
    @State private var generatorShown = false
    
    @EnvironmentObject var randomiserShown: EnvironmentHelpers
    
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.lesson?.date, ascending: true)],
        animation: .default)
    private var ilos: FetchedResults<ILO>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
        animation: .default)
    private var lessons: FetchedResults<Lesson>
    var body: some View {
        VStack {
            /*Picker("Current View", selection: $currentILOView) {
                ForEach(ViewStates.allCases) { state in
                    Text(state.rawValue).tag(state)
                }
            }
            .padding()
            .pickerStyle(SegmentedPickerStyle())*/
            //if currentILOView == .list {
                if ilos.count > 0 {
                    List(ilos) { ilo in
                        VStack(alignment: .leading) {
                            Text(ilo.title!)
                            Label(
                                title: { Text(ilo.lesson!.title ?? "Untitled")
                                    .italic()
                                }, icon: { Image(systemName: Lesson.lessonIcon(type: ilo.lesson!.type)) })
                                .font(.footnote)
                        }
                    }
                    .listStyle(PlainListStyle())
                    Spacer()
                    #if !os(macOS)
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
                    
                #endif
                } else {
                    Text("No Learning Outcomes.  Add outcomes from the lesson info page.")
                }
            /*} else {
                Spacer()
                #if !os(macOS)
                Button(action: {generatorShown = true}, label: {Text("Randomise All ILOs")})
                    .fullScreenCover(isPresented: $generatorShown) {
                        NavigationView {
                            ILOGeneratorView(isPresented: $generatorShown, ilos: ilos.shuffled())
                        }
                    }
                #endif
            }*/
            //Spacer()
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
