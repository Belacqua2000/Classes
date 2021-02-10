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
    
    private enum SplitType: String, CaseIterable, Identifiable {
        var id: String { return self.rawValue }
        case none = "None"
        case newLine = "New Line"
        case comma = ","
        case semicolon = ";"
    }
    
    @State private var currentSplitType: SplitType = .none
    
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
            separatedStrings = batchILOText.components(separatedBy: .newlines).filter({!$0.isEmpty})
        case .semicolon:
            separatedStrings = batchILOText.components(separatedBy: ";")
        case .none:
            separatedStrings = [batchILOText]
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
    
    var addHeader: Text {
        #if os(macOS)
        return Text("Add Learning Outcomes").font(.headline)
        #else
        return Text("Add Learning Outcomes")
        #endif
    }
    
    var editHeader: Text {
        #if os(macOS)
        return Text("Edit Learning Outcome").font(.headline)
        #else
        return Text("Edit Learning Outcome")
        #endif
    }
    
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
    
    var editForm: some View {
        Form {
            Section(header: editHeader) {
                TextField("Outcome Text", text: $iloText)
                    .navigationTitle("Edit Outcome")
            }
        }
        .onAppear(perform: {
            if let ilo = ilo {
                iloText = ilo.title ?? ""
            }
        })
    }
    
    var addForm: some View {
        Form {
            Section(header: addHeader,
                    footer:
                        VStack(alignment: .leading) {
                            Text("To add multiple outcome at once, choose how each outcome is separated:")
                            Picker("Outcomes Separated Using…", selection: $currentSplitType, content: {
                                ForEach(SplitType.allCases) { type in
                                    switch type {
                                    case .comma: Text(",").tag(type)
                                    case .newLine: Image(systemName: "return").tag(type)
                                    case .semicolon: Text(";").tag(type)
                                    case .none: Text("None").tag(type)
                                    }
                                }
                            })
                            .labelsHidden()
                            .pickerStyle(SegmentedPickerStyle())
                            Text("Preview").font(.headline)
                            ForEach(splitILOs) { item in
                                Text("\(item.index). \(item.string)")
                            }
                        },
                    content: {
                        #if os(macOS)
                        TextEditor(text: $batchILOText)
                            .border(Color(.labelColor), width: 1)
                            .frame(height: 100)
                        #else
                        TextEditor(text: $batchILOText)
                            .frame(height: 100)
                        #endif
                    })
        }
    }
    
    var body: some View {
        Group {
            if ilo == nil {
                #if os(macOS)
                addForm
                    .padding()
                #else
                addForm
                #endif
            } else {
                #if os(macOS)
                editForm
                    .padding()
                #else
                editForm
                #endif
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
        }
    }
    
    private func add() {
        if let ilo = ilo {
            ilo.update(in: viewContext, text: iloText, index: ilo.index, lesson: lesson)
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
