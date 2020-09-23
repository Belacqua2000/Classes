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
    #endif
    
    @EnvironmentObject var environmentHelpers: EnvironmentHelpers
    
    @Binding var isPresented: Bool
    @State var ilos: [ILO]
    @State var currentILOIndex = 0
    
    var isFirstILO: Bool {
        return currentILOIndex == 0
    }
    
    var isLastILO: Bool {
        return currentILOIndex >= ilos.count - 1
    }
    
    var body: some View {
        /*GeometryReader { gr in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(ilos) { ilo in
                        let ilo = ilo as ILO
                        Text(ilo.title ?? "No Title")
                            .frame(width: gr.size.width)
                    }
                }
            }
        }*/
        Group {
            if ilos.count != 0 {
                VStack(spacing: 20) {
                    Text(ilos[currentILOIndex].title ?? "No Title")
                        .font(.title)
                    Label(
                        title: { Text(ilos[currentILOIndex].lesson!.title ?? "Untitled").italic() },
                        icon: { Image(systemName: Lesson.lessonIcon(type: ilos[currentILOIndex].lesson?.type)) }
                    )
                    .font(.title3)
                }
            } else {
                Text("No outcomes to Randomise")
                    .font(.title)
            }
        }
        .onChange(of: horizontalSizeClass, perform: { value in
            presentationMode.wrappedValue.dismiss()
        })
        .navigationTitle("Outcome Randomiser")
        .toolbar {
            #if !os(macOS)
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: previousILO, label: {
                    Label("Previous", systemImage: "chevron.left")
                })
                .disabled(isFirstILO)
                
                Spacer()
                
                ilos.count == 0 ? Text("").disabled(true) : Text("Outcome \(currentILOIndex + 1) of \(ilos.count)")
                    .disabled(true)
                
                Spacer()
                
                Button(action: nextILO, label: {
                    Label("Next", systemImage: "chevron.right")
                })
                .disabled(isLastILO)
            }
            #endif
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    environmentHelpers.iloRandomiserShown = false
                }, label: {
                    Text("Close")
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
        NavigationView {
            ILOGeneratorView(isPresented: .constant(true), ilos: [])
        }
    }
}
