//
//  Version4.swift
//  Classes
//
//  Created by Nick Baughan on 05/03/2021.
//

import SwiftUI

struct Version4: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))], animation: .default)
    private var tags: FetchedResults<Tag>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
                  animation: .default)
    private var topics: FetchedResults<Lesson>
    
    var taglessTopics: [Lesson] {
        return topics.filter({($0.tag?.allObjects.isEmpty ?? true)})
    }
    
    #if os(iOS)
    @Environment(\.editMode) var editMode
    #endif
    
    @State var selection = Set<Lesson>()
    @State var itemToPresent: Lesson?
    @State private var addLessonPresented = false
    @State var lesson: Lesson?
    
    var title: String
    
    var body: some View {
        GeometryReader { gr in
            List(selection: $selection) {
                Section(header:
                            Text("Details")
                            .foregroundColor(.accentColor)
                            .textCase(.none)
                            .font(.system(.headline, design: .rounded))
                ) {
                    VStack {
                        HStack {
                            Text("Exam Date:")
                            Spacer()
                            Text(makeDate(year: 2021, month: 7, day: 10, hr: 10, min: 0, sec: 0), style: .relative)
                        }
                        HStack {
                            Text("Number of Topics:")
                            Spacer()
                            Text("112")
                        }
                        HStack {
                            Text("Topics completed:")
                            Spacer()
                            Text("28")
                        }
                        CustomGradient(red: 11, orange: 22, green: 33)
                            .frame(height: 20)
                            .cornerRadius(10)
                    }.font(.system(.body, design: .rounded))
                    
//                    VStack {
//                        HStack {
//                            Spacer()
//                            //                        Picker(selection: .constant(1), label: Label("Picker", systemImage: "line.horizontal.3.decrease.circle")
//                            //                                .labelStyle(IconOnlyLabelStyle()), content: {
//                            //                            Label("Completed", systemImage: "tag").tag(1)
//                            //                            Label("Red", systemImage: "star").tag(2)
//                            //                        })
//                            //                        .pickerStyle(MenuPickerStyle())
//                        }
//                        GeometryReader { gr in
//                            ScrollView(.horizontal) {
//                                HStack(alignment: .bottom) {
//                                    VStack {
//                                        Text("100%").bold()
//                                        Spacer()
//                                        Text("0%").bold()
//                                    }
//                                    ForEach(tags) { item in
//                                        VStack {
//                                            RoundedRectangle(cornerRadius: 12)
//                                                //                                        .background(LinearGradient(gradient: Gradient(), startPoint: .top, endPoint: .bottom))
//                                                .foregroundColor(item.swiftUIColor)
//                                                .frame(height: gr.size.height * CGFloat((item.lesson?.allObjects as? [Lesson] ?? []).filter({$0.watched == true}).count) / CGFloat((item.lesson?.allObjects as? [Lesson] ?? []).count))
//                                            Text(item.name ?? "Untitled").lineLimit(2)
//                                        }
//                                        .frame(width: 50)
//                                    }
//                                }
//                            }
//                            //                        .padding(.vertical)
//                            //                        .padding()
//                            //                .border(Color.accentColor, width: 10)
//                            .cornerRadius(8)
//                        }
//                    }
////                    .padding()
//                    .frame(width: gr.size.width, height: gr.size.height * 0.3)
                }
                
                Section(header:
                            Text("Topics")
                            .foregroundColor(Color("Accent2"))
                            .textCase(.none)
                            .font(.system(.headline, design: .rounded))
                ) {
                    ForEach(tags) { tag in
                        DisclosureGroup(
                            content: {
                                ForEach(tag.lesson?.allObjects as? [Lesson] ?? [], id: \.self) { item in
                                    TopicRow4(item: item, itemToPresent: $itemToPresent)
                                }
                            },
                            label: {
                                Version4Row(tag: tag)
                            }
                        )
                        .listItemTint(tag.swiftUIColor)
                    }
                    DisclosureGroup(
                        content: {
                            ForEach(taglessTopics, id: \.self) { item in
                                TopicRow4(item: item, itemToPresent: $itemToPresent)
                            }
                        },
                        label: {
                            Label("Topics with No Tags", systemImage: "tag.slash")
                        }
                    )
//                    .listItemTint(tag.swiftUIColor)
                }
            }
            .sheet(item: $itemToPresent) { item in
                #if os(macOS)
                TopicView(topic: item)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close", action: {itemToPresent = nil})
                        }
                    }
                #else
                NavigationView {
                    TopicView(topic: item)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close", action: {itemToPresent = nil})
                            }
                        }
                }
                #endif
            }
        }
        .toolbar {
            #if os(iOS)
//            ToolbarItem(placement: .primaryAction) {
//                EditButton()
//            }
            #endif
            ToolbarItem(placement: .primaryAction) {
                Button(action: {addLessonPresented = true}, label: { Label("Add Topic", systemImage: "plus") })
                    .sheet(isPresented: $addLessonPresented) {
                        AddLessonView(lesson: $lesson, isPresented: $addLessonPresented)
                    }
            }
        }
        .navigationTitle(title)
    }
    
    func makeDate(year: Int, month: Int, day: Int, hr: Int, min: Int, sec: Int) -> Date {
        let calendar = Calendar.current
        // calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: year, month: month, day: day, hour: hr, minute: min, second: sec)
        return calendar.date(from: components)!
    }
}

struct Version4Row: View {
    @ObservedObject var tag: Tag
    
    var body: some View {
        HStack {
            Label(
                title: {
                    VStack(alignment: .leading) {
                        Text(tag.name ?? "Untitled").font(.system(.headline, design: .rounded))
                        
                        if !(tag.lesson?.allObjects as? [Lesson] ?? []).isEmpty {
                            ProgressView(value: Double((tag.lesson?.allObjects as? [Lesson] ?? []).filter({$0.watched == true}).count) / Double((tag.lesson?.allObjects as? [Lesson] ?? []).count))
                                .progressViewStyle(LinearProgressViewStyle(tint: tag.swiftUIColor ?? .accentColor))
                            //                        .frame(width: gr.size.width / 2)
                        }
                    }
                },
                icon: {
                    Image(systemName: "tag")
                })
            Spacer()
            Group {
                Label("0", systemImage: "circle.fill").foregroundColor(.red)
                Label("\((tag.lesson?.allObjects as? [Lesson] ?? []).count)", systemImage: "circle.fill").foregroundColor(.orange)
                Label("0", systemImage: "circle.fill").foregroundColor(.green)
            }
            .labelStyle(VerticalLabelStyle())
        }
    }
    
    struct VerticalLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            VStack {
                configuration.icon
                configuration.title
                    .font(.system(.footnote, design: .rounded))
            }
        }
    }
    
    //    struct ProgressStyle: ProgressViewStyle {
    //        var color: Color
    //        func makeBody(configuration: Configuration) -> some View {
    //            ProgressView(configuration)
    //                .background(color)
    //        }
    //    }
    
    
}

struct TopicRow4: View {
    @ObservedObject var item: Lesson
    @Binding var itemToPresent: Lesson?
    
    #if os(iOS)
    let buttonStyle = BorderlessButtonStyle()
    #else
    let buttonStyle = DefaultButtonStyle()
    #endif
    
    var body: some View {
        HStack {
            //                                        if editMode?.wrappedValue == .active {
            //                                            Image(systemName: "checkmark.circle.fill")
            //                                        }
            Label(title: {
                VStack(alignment: .leading) {
                    Text(item.title ?? "Untitled")
                        .font(.system(.headline, design: .rounded))
                    Text("\(item.ilo?.allObjects.count ?? 0) subtasks")
                        .font(.system(.footnote, design: .rounded))
                }
            }, icon: {
                Image(systemName: "circle.fill")
                    .foregroundColor(.orange)
            })
            Spacer()
            if item.watched {
                Image(systemName: "checkmark.circle.fill")
                    .renderingMode(.original)
            }
            Button("Details", action: {itemToPresent = item})
                .foregroundColor(.accentColor)
                .buttonStyle(buttonStyle)
            //                                            .labelsHidden(true)
        }
    }
}

struct Version4_Previews: PreviewProvider {
    static var previews: some View {
        Version4(title: "Title")
    }
}
