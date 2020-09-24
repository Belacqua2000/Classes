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
    
    var body: some View {
        if url != nil {
            Text("There are URLs to import")
            Button("Import", action: addLessons)
                .navigationTitle("Import Lessons")
        } else {
            Text("Could not find lessons in URL")
            Button("Close", action: {isPresented = false})
                .navigationTitle("Import Lessons")
        }
    }
    
    func addLessons() {
        Lesson.parseJSON(url: url!, context: viewContext)
        isPresented = false
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView(isPresented: .constant(true), url: .constant(nil))
    }
}
