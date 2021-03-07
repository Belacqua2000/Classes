//
//  ExamView3.swift
//  Classes
//
//  Created by Nick Baughan on 03/03/2021.
//

import SwiftUI

struct ExamView3: View {
    @State var addLessonPresented = false
    @State var lesson: Lesson?
    var tag: Tag?
    
//    init(tag: Tag? = nil) {
//        self.tag = tag
//        #if os(iOS)
//        UITableView.appearance().backgroundColor = .clear
//        #else
//        #endif
//    }
    
    #if os(macOS)
    let listStyle = InsetListStyle()
    #else
    let listStyle = InsetGroupedListStyle()
    #endif
    
    @FetchRequest(entity: Lesson.entity(), sortDescriptors: [], predicate: nil, animation: .default)
    var lessons: FetchedResults<Lesson>
    
    var filteredTopics: [Lesson] {
        if let tag = tag {
            return lessons.filter({($0.tag?.contains(tag) ?? true)}).sorted(by: {$0.date ?? Date() < $1.date ?? Date()})
        } else {
            return Array(lessons).sorted(by: {$0.date ?? Date() < $1.date ?? Date()})
        }
    }
    
    @State var selection = Set<Lesson>()
    
    var body: some View {
        List(selection: $selection) {
            
            Section(header: Text("Tag Details").font(.system(.title, design: .rounded)).bold().foregroundColor(.accentColor).textCase(.lowercase)) {
                VStack(alignment: .leading) {
                    Text("Tag: \(tag?.name ?? "Untitled")")
                    Text("No. of Lessons: \(filteredTopics.count)")
                }
            }
            
            Section(header: Text("Topics").font(.system(.title, design: .rounded)).bold().foregroundColor(.accentColor).textCase(.lowercase)) {
                ForEach(filteredTopics, id: \.self) { topic in
                    NavigationLink(
                        destination: TopicView(topic: topic),
                        label: {
                            HStack {
                                Label(title: {
                                    VStack(alignment: .leading) {
                                        Text(topic.title ?? "Untitled")
                                            .font(.system(.headline, design: .rounded))
                                        Text("20 subtasks")
                                            .font(.system(.footnote, design: .rounded))
                                    }
                                }, icon: {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.orange)
                            })
                                Spacer()
                                Image(systemName: "pencil.circle.fill")
                                Image(systemName: "pencil.circle.fill")
                            }                        })
                }
            }
        }
        .listStyle(listStyle)
        .background(LinearGradient(gradient: .init(colors: [.blue, .orange]), startPoint: .top, endPoint: .bottom).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {addLessonPresented = true}, label: { Label("Add Topic", systemImage: "plus") })
                    .sheet(isPresented: $addLessonPresented) {
                        AddLessonView(lesson: $lesson, isPresented: $addLessonPresented)
                    }
            }
        }
        .navigationTitle(tag?.name ?? "All Tags")
    }
}

struct ExamView3_Previews: PreviewProvider {
    static var previews: some View {
        ExamView3()
    }
}
