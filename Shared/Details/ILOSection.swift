//
//  ILOSection.swift
//  Classes
//
//  Created by Nick Baughan on 18/09/2020.
//

import SwiftUI

struct ILOSection: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var lesson: Lesson
    
    @State var isAddingILO: Bool = false
    @State private var selectedILO: ILO? = nil
    @State var editILOViewState: EditILOView.AddOutcomeViewState = .single
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.index, ascending: true), NSSortDescriptor(keyPath: \ILO.title, ascending: true)],
        animation: .default)
    private var ilos: FetchedResults<ILO>
    var filteredILOs: [ILO] {
        return ilos.filter { $0.lesson == lesson }
    }
    
    var listHeight: CGFloat {
        #if os(macOS)
        return 100
        #else
        return 200
        #endif
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if filteredILOs.count > 0 {
                #if !os(macOS)
                EditButton()
                #endif
                List {
                    ForEach(filteredILOs) { ilo in
                        HStack {
                            Text("\(ilo.index + 1). \(ilo.title ?? "")")
                            Spacer()
                            Button(action: { toggleILOWritten(ilo: ilo) }, label: {
                                ilo.written ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "checkmark.circle")
                            })
                            .contextMenu(ContextMenu(menuItems: {
                                Button(action: {
                                    selectedILO = ilo
                                    isAddingILO = true
                                }, label: {
                                    Label("Edit", systemImage: "square.and.pencil")
                                })
                                Button(action: {
                                    copyILO(ilo)
                                }, label: {
                                    Label("Copy Learning Outcome", systemImage: "doc")
                                })
                            }))
                        }
                    }
                    .onDelete(perform: deleteILOs)
                    .onMove(perform: moveILOs)
                }
                .cornerRadius(10)
                .frame(height: listHeight)
            }
            
            HStack {
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
                Spacer()
            }
            .sheet(isPresented: $isAddingILO, onDismiss: {
                selectedILO = nil
                editILOViewState = .single
            }, content: {
                #if !os(macOS)
                NavigationView {
                    EditILOView(currentViewState: $editILOViewState, isPresented: $isAddingILO, ilo: $selectedILO, lesson: lesson)
                        .environment(\.managedObjectContext, viewContext)
                        .navigationTitle("Add Outcome")
                }
                .navigationViewStyle(StackNavigationViewStyle())
                #else
                EditILOView(currentViewState: $editILOViewState, isPresented: $isAddingILO, ilo: $selectedILO, lesson: lesson)
                #endif
            })
            .padding(.vertical)
        }
    }
    
    private func moveILOs(from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [ ILO ] = filteredILOs.map{ $0 }
        
        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination )
        
        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride( from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].index =
                Int16( reverseIndex )
        }
        do {
            try viewContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
    
    private func deleteILOs(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredILOs[$0] }.forEach { ilo in
                ilo.delete(context: viewContext, save: false)
            }
            saveOnDelay()
        }
    }
    
    private func saveOnDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try viewContext.save()
            } catch {
                print(error)
            }
            lesson.updateILOIndices(in: viewContext, save: true)
        }
    }
    
    private func copyILO(_ ilo: ILO) {
        #if !os(macOS)
        UIPasteboard.general.string = ilo.title
        #endif
    }
    
    
    func toggleILOWritten(ilo: ILO) {
        withAnimation {
            ilo.toggleWritten(context: viewContext)
        }
    }
}
