//
//  EditILOView.swift
//  Classes
//
//  Created by Nick Baughan on 10/09/2020.
//

import SwiftUI

struct EditILOView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    // Text storage
    @State var iloText: String = ""
    @State var batchILOText: String = ""
    
    enum AddOutcomeViewState: String {
        case single, multiple
    }
    
    @Binding var currentViewState: AddOutcomeViewState
    
    private enum SplitType: String, CaseIterable, Identifiable {
        var id: String { return self.rawValue }
        case comma = ","
        case newLine = "New Line"
        case semicolon = ";"
    }
    
    @State private var currentSplitType: SplitType = .comma
    
    private struct SplitILO: Identifiable {
        var id = UUID()
        var index: Int
        var string: String
    }
    
    private var splitILOs: [SplitILO] {
        var array = [SplitILO]()
        var separatedStrings: [String] = []
        
        switch currentSplitType {
        case .comma:
            separatedStrings = batchILOText.components(separatedBy: ",")
        case .newLine:
            separatedStrings = batchILOText.components(separatedBy: .newlines)
        case .semicolon:
            separatedStrings = batchILOText.components(separatedBy: ";")
        }
        
        var index = 1
        for string in separatedStrings {
            array.append(SplitILO(index: index, string: string))
            index += 1
        }
        return array
    }
    
    @Binding var isPresented: Bool
    @Binding var ilo: ILO?
    var lesson: Lesson
    
    var saveButton: some View {
        Button(action: add, label: {
            Text("Save")
        })
        .disabled(iloText == "" && batchILOText == "")
        .keyboardShortcut(.defaultAction)
    }
    
    var cancelButton: some View {
        Button(action: cancel, label: {
            Text("Cancel")
        })
        .keyboardShortcut(.cancelAction)
    }
    
    var singleSelection: some View {
        Section(header: Text("Add Single Learning Outcome")) {
            TextField("Outcome Text", text: $iloText)
                .navigationTitle("Add Outcome")
        }
    }
    
    var body: some View {
        Form {
            if currentViewState == .single {
                #if os(macOS)
                Section(header: Text("Add Learning Outcome").font(.headline)) {
                    TextField("Outcome Text", text: $iloText)
                }
                HStack {
                    Spacer()
                    cancelButton
                    saveButton
                }
                #else
                singleSelection
                #endif
            } else {
                Section(header: Text("Add Multiple Learning Outcome"),
                        footer:
                            VStack(alignment: .leading) {
                                Text("Separate learning outcomes are separated using:")
                                Picker("Separate Items Using...", selection: $currentSplitType, content: {
                                    ForEach(SplitType.allCases) { type in
                                        switch type {
                                        case .comma: Text(",").tag(type)
                                        case .newLine: Image(systemName: "return").tag(type)
                                        case .semicolon: Text(";").tag(type)
                                        }
                                    }
                                })
                                .pickerStyle(SegmentedPickerStyle())
                                Text("Preview")
                                ForEach(splitILOs) { item in
                                    Text("\(item.index). \(item.string)")
                                }
                            },
                        content: {
                            TextEditor(text: $batchILOText)
                                .frame(height: 100)
                        })
            }
        }
        .onAppear(perform: {
            if let ilo = ilo {
                iloText = ilo.title ?? ""
            }
        })
        .frame(idealWidth: 300, idealHeight: 50)
        .toolbar {
            #if !os(macOS)
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
            #endif
        }
    }
    
    private func add() {
        if currentViewState == .single {
            if let ilo = ilo {
                ilo.update(in: viewContext, text: iloText, index: ilo.index, lesson: lesson)
            } else {
                ILO.create(in: viewContext, title: iloText, index: lesson.ilo?.count ?? 0, lesson: lesson)
            }
        } else {
            for ilo in splitILOs {
                ILO.create(in: viewContext, title: ilo.string, index: lesson.ilo?.count ?? 0, lesson: lesson)
            }
        }
        lesson.updateILOIndices(in: viewContext, save: true)
        isPresented = false
    }
    
    private func cancel() {
        isPresented = false
    }
}
/*
 struct EditView_Previews: PreviewProvider {
 static var previews: some View {
 EditILOView()
 }
 }*/
