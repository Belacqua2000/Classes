//
//  LessonsListWatch.swift
//  ClassesWatchApp Extension
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct LessonsListWatch: View {
    
    var listType: LessonsListType = .init(filterType: .all)
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)], animation: .default)
    private var lessons: FetchedResults<Lesson>
    
    @State private var alertPresented: Bool = false
    let alert = {Alert(title: Text("No Lessons"), message: Text("Lessons can be created from other devices and will sync to your watch automatically via iCloud.  If your lessons are not appearing, please ensure iCloud is enabled on all of your devices.  If you still have trouble, please contact support."), dismissButton: .default(Text("Dismiss")))}
    
    var body: some View {
        if lessons.isEmpty {
            List(lessons) { lesson in
                Text(lesson.title ?? "Untitled")
            }
            .navigationTitle("All Lessons")
        } else {
            VStack {
                Text("There are no lessons in this view.  Lessons can be added on iPhone, iPad and Mac.")
                Button("Learn More", action: showAlert)
                    .alert(isPresented: $alertPresented, content: alert)
            }
                .navigationTitle("All Lessons")
        }
    }
    
    private func showAlert() {
        alertPresented = true
    }
    
}

struct LessonsListWatch_Previews: PreviewProvider {
    static var previews: some View {
        LessonsListWatch()
    }
}
