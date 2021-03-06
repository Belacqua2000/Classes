//
//  ILOSection.swift
//  Classes
//
//  Created by Nick Baughan on 18/09/2020.
//

import SwiftUI

struct ILOSection: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var viewStates: DetailViewStates
    @ObservedObject var lesson: Lesson
    
    @State private var selectedILO: ILO? = nil
    
    let nc = NotificationCenter.default
    
    var filteredILOs: [ILO] {
        let ilos = lesson.ilo?.allObjects as? [ILO]
        return ilos?.sorted(by: {$0.index < $1.index}) ?? []
    }
    
    var completedILOs: Double {
        let iloCount = Double(filteredILOs.count)
        let completedILOs = Double(filteredILOs.filter({$0.written}).count)
        let value = completedILOs / iloCount
        return iloCount == 0 ? 1 : value
    }
    
    var listHeight: CGFloat {
        #if os(macOS)
        return 200
        #else
        return 200
        #endif
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Label("Learning Outcomes", systemImage: "list.number")
                    .font(.headline)
            if filteredILOs.count > 0 {
                ILOsProgressView(completedILOs: completedILOs)
                #if !os(macOS)
                EditButton()
                #endif
                List {
                    ForEach(filteredILOs) { ilo in
                        HStack {
                            HStack(alignment: .firstTextBaseline) {
                                Text("\(ilo.index + 1).").bold()
                                Text("\(ilo.title ?? "")")
                            }
                            Spacer()
                            Button(action: { toggleILOWritten(ilo: ilo) }, label: {
                                ilo.written ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "checkmark.circle")
                            })
                            .help(ilo.written ? "Mark unwritten" : "Mark written")
                        }
                        .onDrag({
                            return NSItemProvider(object: NSString(string: ilo.title ?? "Untitled"))
                        })
                        .contextMenu(ContextMenu(menuItems: {
                            Button(action: {
                                selectedILO = ilo
                                viewStates.addILOPresented = true
                            }, label: {
                                Label("Edit", systemImage: "square.and.pencil")
                            })
                            Button(action: {
                                copyILO(ilo)
                            }, label: {
                                Label("Copy Outcome", systemImage: "doc.on.doc")
                            })
                            Button(action: {
                                withAnimation {
                                    ilo.delete(context: viewContext, save: true)
                                }
                            }, label: {
                                Label("Delete", systemImage: "trash")
                            })
                        }))
                    }
                    .onDelete(perform: deleteILOs)
                    .onMove(perform: moveILOs)
                }
                .cornerRadius(8)
                .frame(height: listHeight)
            } else {
                HStack {
                    #if os(macOS)
                    Text("No learning outcomes.  To add, press \(Image(systemName: "text.badge.plus")) in the toolbar.")
                        .fixedSize(horizontal: false, vertical: true)
                    #else
                    Text("No learning outcomes.")
                    #endif
                    Spacer()
                }
            }
            
            HStack {
                #if os(iOS)
                AddILOMenu(detailStates: viewStates)
                Spacer()
                #endif
            }
            .onReceive(nc.publisher(for: .addILO), perform: { _ in
                viewStates.addILOPresented = true
            })
            .sheet(isPresented: $viewStates.addILOPresented, onDismiss: {
                selectedILO = nil
            }, content: {
                #if !os(macOS)
                NavigationView {
                    EditILOView(isPresented: $viewStates.addILOPresented, ilo: $selectedILO, lesson: lesson)
                        .environment(\.managedObjectContext, viewContext)
                        .navigationTitle("Add Outcome")
                }
                .navigationViewStyle(StackNavigationViewStyle())
                #else
                EditILOView(isPresented: $viewStates.addILOPresented, ilo: $selectedILO, lesson: lesson)
                #endif
            })
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
        lesson.objectWillChange.send()
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
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(ilo.title ?? "", forType: .string)
        #endif
    }
    
    
    func toggleILOWritten(ilo: ILO) {
        withAnimation {
            ilo.toggleWritten(context: viewContext)
        }
    }
}
