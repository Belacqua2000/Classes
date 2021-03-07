//
//  TopicView.swift
//  Classes
//
//  Created by Nick Baughan on 27/02/2021.
//

import SwiftUI

struct TopicView: View {
    
    @ObservedObject var topic: Lesson
    @State var addILOShowing = false
    @State var addTagShowing = false
    @State var ilo: ILO?
    
    var ilos: [ILO] {
        return topic.ilo?.allObjects as! [ILO]
    }
    
    var links: [Resource] {
        return topic.resource?.allObjects as! [Resource]
    }
    
    let subtopics = ["Define Heart Failure", "List risk factors of Heart Failure", "Recognise the signs and symptoms of Heart Failure", "Explain management options for Heart Failure", "Know the complications of Heart Failure"]
    
    let questions = ["What is the mechanism of action of ramipril?", "What are the physiological compensatory measures of heart failure?"]
    
    #if os(macOS)
    let listStyle = InsetListStyle()
    #else
    let listStyle = InsetGroupedListStyle()
    #endif
    
    var body: some View {
        List {
            Section(header:
                        Text("Details:")
                        .bold()
                        .font(.system(.title, design: .rounded))
                        .foregroundColor(.accentColor)
                        .textCase(.none)
            ) {
                ToggleWatchedButton(lesson: topic)
                Button(action: {addTagShowing = true}) {
                    Label("Edit Tags", systemImage: "tag")
                }
                .popover(isPresented: $addTagShowing) {
                    AllocateTagView(selectedTags:
                                        Binding(
                                            get: {topic.tag!.allObjects as! [Tag]},
                                            set: {
                                                for tag in topic.tag!.allObjects as! [Tag] {
                                                    topic.removeFromTag(tag)
                                                }
                                                for tag in $0 {
                                                    topic.addToTag(tag)
                                                }
                                            })
                                    
                    )
                }
            }
            Section(header:
                        Text("Study Sessions:")
                        .bold()
                        .font(.system(.title, design: .rounded))
                        .foregroundColor(.accentColor)
                        .textCase(.none)
            ) {
//                    Rectangle()
//                        .stroke(Color.blue, lineWidth: 5)
//                        .frame(width: 300, height: 100)
//                        .padding()
                    ForEach(0..<5) {_ in
                        let rating = Int.random(in: 0..<5)
                        HStack {
                            Text(Date(), style: .date)
                            Spacer()
                            ForEach(0..<rating) { _ in
                                Image(systemName: "star.fill")
                                    .renderingMode(.original)
                            }
                        }
                    }
                Button(action: {}, label: {
                    Label("Add Study Session", systemImage: "plus")
                })
            }
            
            
            Section(header:
                        Text("Subtopics:")
                        .bold()
                        .font(.system(.title, design: .rounded))
                        .foregroundColor(.accentColor)
                        .textCase(.none)
            )
            {
                
                ForEach(ilos) { item in
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(item.index + 1).").bold()
                        Text(item.title ?? "No title")
                        Spacer()
                    }
                }
                .listRowBackground(Color("Accent2"))
            }
                Section(header:
                            Text("Questions:")
                                .bold()
                                .font(.system(.title, design: .rounded))
                            .foregroundColor(.accentColor)
                            .textCase(.none)
                ) {
                ForEach(questions.indices, id: \.self) { item in
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(item + 1).").bold()
                        Text(questions[item])
                        Spacer()
                    }
                }
                .listRowBackground(Color("Accent3"))
            }
            
            Section(header:
                        Text("Links:")
                            .bold()
                            .font(.system(.title, design: .rounded))
                        .foregroundColor(.accentColor)
                        .textCase(.none)
            ) {
                ForEach(links) { item in
                    HStack(alignment: .firstTextBaseline) {
                        Text(item.name ?? "Untitled")
                        Spacer()
                        Link(item.url?.host ?? "No Title", destination: (item.url ?? URL(string: "https://www.nickbaughanapps.wordpress.com"))!)
                    }
                }
                .listRowBackground(Color(red: 0.690, green: 0.949, blue: 0.706, opacity: 1.000))
        }
        }
        .listStyle(listStyle)
        .navigationTitle(topic.title ?? "Untitled Lesson")
//        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $addILOShowing, content: {
            #if os(macOS)
            EditILOView(isPresented: $addILOShowing, ilo: $ilo, lesson: topic)
            #else
            NavigationView {
                EditILOView(isPresented: $addILOShowing, ilo: $ilo, lesson: topic)
                    .navigationTitle("Add Subtopic")
            }
            #endif
        })
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {addILOShowing = true}) {
                    Label("Add Learning Outcome", systemImage: "text.badge.plus")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button(action: {addTagShowing = true}) {
                    Label("Edit Tags", systemImage: "tag")
                }
                .popover(isPresented: $addTagShowing) {
                    AllocateTagView(selectedTags:
                                        Binding(
                                            get: {topic.tag!.allObjects as! [Tag]},
                                            set: {
                                                for tag in topic.tag!.allObjects as! [Tag] {
                                                    topic.removeFromTag(tag)
                                                }
                                                for tag in $0 {
                                                    topic.addToTag(tag)
                                                }
                                            })
                                    
                    )
                }
            }
        }
    }
}

//struct TopicView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            TopicView()
//        }
//    }
//}
