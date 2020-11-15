//
//  ILOGeneratorView.swift
//  Classes
//
//  Created by Nick Baughan on 18/09/2020.
//

import SwiftUI

struct ILOGeneratorView: View {
    @Environment(\.presentationMode) var presentationMode
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #else
    @State var horizontalSizeClass = false
    #endif
    @EnvironmentObject var environmentHelpers: EnvironmentHelpers
    
    @Binding var isPresented: Bool
    
    @State var writtenFilterActive = true
    
    var ilos: [ILO]
    var filteredILOs: [ILO] {
        return writtenFilterActive ? ilos.filter({$0.written}) : ilos
    }
    @State var currentILOIndex = 0
    
    var isFirstILO: Bool {
        return currentILOIndex == 0
    }
    
    var isLastILO: Bool {
        return currentILOIndex >= filteredILOs.count - 1
    }
    
    var previousButton: some View {
        Button(action: previousILO, label: {
            Label("Previous", systemImage: "chevron.left")
        })
        .disabled(isFirstILO)
    }
    
    var nextButton: some View {
        Button(action: nextILO, label: {
            Label("Next", systemImage: "chevron.right")
        })
        .disabled(isLastILO)
    }
    
    var body: some View {
        Group {
            if filteredILOs.count != 0 {
                VStack {
                    Spacer()
                    HStack {
                        #if os(macOS)
                        previousButton
                            .padding()
                        #endif
                        Spacer()
                        VStack(spacing: 20) {
                            Spacer()
                            Text(filteredILOs[currentILOIndex].title ?? "No Title")
                                .font(.title)
                            Label(
                                title: { Text(filteredILOs[currentILOIndex].lesson!.title ?? "Untitled").italic() },
                                icon: { Image(systemName: Lesson.lessonIcon(type: filteredILOs[currentILOIndex].lesson?.type)) }
                            )
                            .font(.title3)
                            Spacer()
                        }
                        Spacer()
                        #if os(macOS)
                        nextButton
                            .padding()
                        #endif
                    }
                    Spacer()
                    HStack {
                        Toggle(isOn: $writtenFilterActive, label: {
                            Text("Only Show Written")
                        })
                        Spacer()
                        #if os(macOS)
                        filteredILOs.count == 0 ? Text("").disabled(true) : Text("Outcome \(currentILOIndex + 1) of \(filteredILOs.count)")
                            .disabled(true)
                        #endif
                    }.padding()
                }
            } else {
                Text("No outcomes to Randomise")
                    .font(.title)
            }
        }
        .navigationTitle("Outcome Randomiser")
        .toolbar {
            #if !os(macOS)
            ToolbarItemGroup(placement: .bottomBar) {
                previousButton
                
                Spacer()
                
                filteredILOs.count == 0 ? Text("").disabled(true) : Text("Outcome \(currentILOIndex + 1) of \(filteredILOs.count)")
                    .disabled(true)
                
                Spacer()
                
                nextButton
            }
            #endif
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", action: {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
    
    func previousILO() {
        guard !isFirstILO else { return }
            currentILOIndex -= 1
    }
    
    func nextILO() {
        guard !isLastILO else { return }
            currentILOIndex += 1
    }
    
}

struct ILOGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
            ILOGeneratorView(isPresented: .constant(true), ilos: [])
    }
}
