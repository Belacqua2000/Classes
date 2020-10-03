//
//  ImportView.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI

struct ImportView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var isPresented: Bool
    @Binding var url: URL?
    
    @State var imported = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if url != nil {
                    Text("Lessons found in the file.  Press to import into the app.")
                } else {
                    Text("Could not find lessons in file")
                }
                Button("Import", action: addLessons)
                    .padding(20)
                    .frame(width: 200)
                    .cornerRadius(5)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .disabled(url == nil || imported == true)
                if imported {
                    Text("Lessons have been imported")
                }
            }
            .navigationTitle("Import Lessons")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: {isPresented = false})
                }
            }
        }
    }
    
    func addLessons() {
        Lesson.parseJSON(url: url!, context: viewContext)
        imported = true
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ImportView(isPresented: .constant(true), url: .constant(nil))
        }
    }
}
