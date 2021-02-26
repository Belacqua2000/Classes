//
//  LessonDetailsWatch.swift
//  ClassesWatchApp Extension
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct LessonDetailsWatch: View {
    
    @Environment(\.managedObjectContext) var viewContext
    
    @ObservedObject var lesson: Lesson
    
    var ilos: [ILO] {
        return (lesson.ilo?.allObjects as! [ILO]).sorted(by: { $0.index < $1.index })
    }
    var completedILOs: Double {
        let iloCount = Double(ilos.count)
        let completedILOs = Double(ilos.filter({$0.written}).count)
        let value = completedILOs / iloCount
        return iloCount == 0 ? 1 : value
    }
    
    var tags: [Tag] {
        return lesson.tag?.allObjects as! [Tag]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Label(lesson.title ?? "Untitled", systemImage: "")
                    .font(.headline)
                Label(title: {Text(lesson.date ?? Date(), style: .date)}, icon: {Image(systemName: "calendar")})
                if let location = lesson.location, !location.isEmpty {
                    Label(location, systemImage: "mappin")
                }
                if let teacher = lesson.teacher, !teacher.isEmpty {
                    Label(teacher, systemImage: "graduationcap")
                }
                ToggleWatchedButton(lesson: lesson)
                    .animation(nil)
                
                if !tags.isEmpty {
                    Text("Tags")
                        .font(.headline)
                        .padding(.top)
                    ForEach(tags) { tag in
                        Label(title: {
                            Text(tag.name ?? "Untitled")
                        }, icon: {
                            Image(systemName: "tag")
                                .foregroundColor(tag.swiftUIColor)
                        })
                        .font(.footnote)
                    }
                }
                
                Text("Learning Outcomes")
                    .font(.headline)
                    .padding(.top)
                
                if !ilos.isEmpty {
                    ILOsProgressView(completedILOs: completedILOs)
                } else {
                    Text("No learning outcomes")
                }
                
                ForEach(ilos) { ilo in
                    Button(action: {toggleILOComplete(ilo: ilo)}, label: {
                        HStack {
                            Text(ilo.title ?? "Untitled ILO")
                            Spacer()
                            Image(systemName: !ilo.written ? "xmark.circle" : "checkmark.circle.fill")
                        }
                    })
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Button", action: {})
    //                ToggleWatchedButton()
                }
            }
        }
        .navigationTitle("Lesson Details")
    }
    
    private func toggleILOComplete(ilo: ILO) {
        withAnimation {
            ilo.toggleWritten(context: viewContext)
        }
    }
    
}

struct LessonDetailsWatch_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        NavigationView {
            LessonDetailsWatch(lesson: Lesson.sampleData(context: context).first!)
        }
    }
}
