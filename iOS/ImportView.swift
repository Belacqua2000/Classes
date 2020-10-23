//
//  ImportView.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI

struct ImportView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
//    @Binding var isPresented: Bool
    @Binding var url: URL?
    
    @State var imported = false
    @State private var alertShown = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if url != nil {
                    Text("Lessons found in the file.  Press to import into the app.")
                    Text("Please note, if any of these lessons are already in the app, they will be reimported.")
                } else {
                    Text("Could not find lessons in file")
                }
                Button(action: showAlert, label: {
                    Text("Import")
                        .padding(20)
                        .frame(width: 200)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                })
                .cornerRadius(10)
                    .disabled(url == nil || imported == true)
                    .alert(isPresented: $alertShown, content: {
                        Alert(
                            title: Text("Confirm Import"),
                            message: Text("Are you sure you want to import?  This will duplicate any lessons that you are importing which are already in Classes."),
                            primaryButton: .destructive(Text("Import"), action: addLessons),
                            secondaryButton: .cancel(Text("Cancel"), action: {alertShown = false}))
                    })
                if imported {
                    Text("Lessons have been imported")
                }
            }
            .padding(.horizontal)
            .navigationTitle("Import Lessons")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
        }
    }
    
    private func showAlert() {
        alertShown = true
    }
    
    private func addLessons() {
        Lesson.parseJSON(url: url!, context: viewContext)
        imported = true
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ImportView(url: .constant(nil))
        }
    }
}
