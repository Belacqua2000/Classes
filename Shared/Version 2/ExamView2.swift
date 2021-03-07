//
//  ExamView2.swift
//  Classes
//
//  Created by Nick Baughan on 27/02/2021.
//

import SwiftUI

struct ExamView2: View {
    
    @State var addLessonPresented = false
    @State var lesson: Lesson?
    
    var tag: Tag?
    
    @FetchRequest(entity: Lesson.entity(), sortDescriptors: [], predicate: nil, animation: .default)
    var lessons: FetchedResults<Lesson>
    
    var filteredTopics: [Lesson] {
        if let tag = tag {
            return lessons.filter({($0.tag?.contains(tag) ?? true)}).sorted(by: {$0.date ?? Date() < $1.date ?? Date()})
        } else {
            return Array(lessons).sorted(by: {$0.date ?? Date() < $1.date ?? Date()})
        }
    }
    
    func random3Array(array: [Lesson]) -> [[Lesson]] {
        return stride(from: 0, to: array.count, by: array.count / 3).map {
            Array(array[$0 ..< Swift.min($0 + array.count / 4, array.count)])
        }
    }
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))], animation: .default)
    private var tags: FetchedResults<Tag>
    
    #if os(macOS)
    let listStyle = InsetListStyle()
    #else
    let listStyle = InsetGroupedListStyle()
    #endif
    
    enum exam: String, Identifiable, CaseIterable {
        var id: String { return rawValue }
        case phase1 = "Phase 1"
        case phase2 = "Phase 2"
        case phase3 = "Phase 3"
        case ssc = "SSC"
    }
    
    enum category: String, Identifiable, CaseIterable {
        var id: String { return rawValue }
        case rating = "star.fill"
        case tag = "tag"
        case all = "list.bullet"
    }
    
    @State var pickerSelection: exam = .ssc
    @State var categoryPickerSelection: category = .rating
    
    var picker: some View {
        Picker(
            selection: $pickerSelection,
            label:
                Text("\(pickerSelection.rawValue) \(Image(systemName: "chevron.down"))")
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(Color(red: 0.372, green: 0.442, blue: 0.687, opacity: 1.000))
                .padding()
            ,
            content: {
                ForEach(exam.allCases) { exam in
                    Text(exam.rawValue)
                        .tag(exam)
                }
            })
    }
    
    var categoryPicker: some View {
        Picker(selection: $categoryPickerSelection, label: Text("Category"), content: {
            ForEach(category.allCases) { category in
                Image(systemName: category.rawValue)
                    .tag(category)
            }
        })
        .pickerStyle(SegmentedPickerStyle())
        .labelsHidden()
    }
    
    //    var listContent: some View {
    //        let arrays = random3Array(array: filteredTopics)
    //        switch categoryPickerSelection {
    //        case .all:
    //            return(
    //                Group {
    //                    ForEach(filteredTopics) { topic in
    //                        ListRow(topic: topic, rating: Int.random(in: 0...3))
    //                    }
    //                })
    //        case .tag:
    //            return(
    //                Group {
    //                    ForEach(tags) { tag in
    //                        DisclosureGroup(
    //                            content: {
    //                                ForEach(tag.lesson?.allObjects as! [Lesson]) { topic in
    //                                    ListRow(topic: topic, rating: Int.random(in: 0...3))
    //                                }
    //                            },
    //                            label: { Label(tag.name ?? "No Name", systemImage: "tag") }).listItemTint(tag.swiftUIColor)
    //                    }
    //                })
    //        case .rating:
    //            return(
    //                Group {
    //                    DisclosureGroup(
    //                        content: {
    //                            ForEach(arrays[0]) { topic in
    //                                ListRow(topic: topic, rating: 0)
    //                            }
    //                        }, label: {Label("No Rating", systemImage: "star.slash")})
    //
    //                    DisclosureGroup(
    //                        content: {
    //                            ForEach(arrays[1]) { topic in
    //                                ListRow(topic: topic, rating: 1)
    //                            }
    //                        }, label: {
    //                            HStack {
    //                                Image(systemName: "star.fill").renderingMode(.original)
    //                                Spacer()
    //                            }
    //                        })
    //                    DisclosureGroup(
    //                        content: {
    //                            ForEach(arrays[2]) { topic in
    //                                ListRow(topic: topic, rating: 2)
    //                            }
    //                        }, label: {
    //                            HStack {
    //                                Image(systemName: "star.fill").renderingMode(.original)
    //                                Image(systemName: "star.fill").renderingMode(.original)
    //                                Spacer()
    //                            }
    //                        })
    //                    DisclosureGroup(
    //                        content: {
    //                            ForEach(arrays[3]) { topic in
    //                                ListRow(topic: topic, rating: 3)
    //                            }
    //                        }, label: {
    //                            HStack {
    //                                Image(systemName: "star.fill").renderingMode(.original)
    //                                Image(systemName: "star.fill").renderingMode(.original)
    //                                Image(systemName: "star.fill").renderingMode(.original)
    //                                Spacer()
    //                            }
    //                        })
    //                })
    //        }
    //        return EmptyView()
    //    }
    //
    var body: some View {
        List {
            Section(
                header:
                    VStack(alignment: .leading) {
                        Text("Exam Details:")
                            .bold()
                            .foregroundColor(Color(red: 0.718, green: 0.631, blue: 0.404, opacity: 1.000))
                            .font(.system(.title, design: .rounded))
                    }
                    .textCase(.none)
            ) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Exam Date: ") + Text(Date(), style: .date)
                        Text("Topics: ") + Text("\(lessons.count)")
                    }
                    Spacer()
                }
                .font(.body)
                .foregroundColor(.primary)
                .listRowBackground(Color(red: 0.843, green: 0.690, blue: 1.000, opacity: 1.000))
            }
            
            Section(
                header:
                    VStack(alignment: .leading) {
                        Text("Topics:")
                            .bold()
                            .textCase(.none)
                            .foregroundColor(Color(red: 0.718, green: 0.631, blue: 0.404, opacity: 1.000))
                        //                        Spacer()
                        //                        Button(action: {}, label: {
                        //                            Text(Image(systemName: "line.horizontal.3.decrease.circle"))
                        //                                .bold()
                        //                        })
                        categoryPicker
                    }
                    .font(.system(.title, design: .rounded))
            ) {
                
                switch categoryPickerSelection {
                case .tag:
                    ForEach(tags) { tag in
                        DisclosureGroup(
                            content: {
                                ForEach(tag.lesson?.allObjects as! [Lesson]) { topic in
                                    ListRow(topic: topic, rating: Int.random(in: 0...3))
                                }
                            },
                            label: { Label(tag.name ?? "No Name", systemImage: "tag") }).listItemTint(tag.swiftUIColor)
                    }
                    
                case .all:
                    ForEach(filteredTopics) { topic in
                        ListRow(topic: topic, rating: Int.random(in: 0...3))
                    }
                case .rating:
                    DisclosureGroup(
                        content: {
                            ForEach(filteredTopics) { topic in
                                ListRow(topic: topic, rating: 0)
                            }
                        }, label: {Label("No Rating", systemImage: "star.slash")})
                    
                    DisclosureGroup(
                        content: {
                            ForEach(filteredTopics) { topic in
                                ListRow(topic: topic, rating: 1)
                            }
                        }, label: {
                            HStack {
                                Image(systemName: "star.fill").renderingMode(.original)
                                Spacer()
                            }
                        })
                    DisclosureGroup(
                        content: {
                            ForEach(filteredTopics) { topic in
                                ListRow(topic: topic, rating: 2)
                            }
                        }, label: {
                            HStack {
                                Image(systemName: "star.fill").renderingMode(.original)
                                Image(systemName: "star.fill").renderingMode(.original)
                                Spacer()
                            }
                        })
                    DisclosureGroup(
                        content: {
                            ForEach(filteredTopics) { topic in
                                ListRow(topic: topic, rating: 3)
                            }
                        }, label: {
                            HStack {
                                Image(systemName: "star.fill").renderingMode(.original)
                                Image(systemName: "star.fill").renderingMode(.original)
                                Image(systemName: "star.fill").renderingMode(.original)
                                Spacer()
                            }
                        })
                }
            }
        }
        .listStyle(listStyle)
        .navigationTitle(pickerSelection.rawValue)
        //        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                picker
                    .pickerStyle(MenuPickerStyle())
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {addLessonPresented = true}, label: { Label("Add Topic", systemImage: "plus") })
                    .sheet(isPresented: $addLessonPresented) {
                        AddLessonView(lesson: $lesson, isPresented: $addLessonPresented)
                    }
            }
        }
    }
}

struct ExamView2_Previews: PreviewProvider {
    static var previews: some View {
        //        #if os(macOS)
        NavigationView {
            List {
                NavigationLink(
                    destination: ExamView2(),
                    label: {
                        Label("SSC", systemImage: "graduationcap")
                    })
                Section(header: Label("Phase 3", systemImage: "graduationcap")) {
                    NavigationLink(
                        destination: ExamView2(),
                        label: {
                            Label("All Outcomes", systemImage: "graduationcap")
                        })
                }
                
                DisclosureGroup(
                    content: {
                        NavigationLink(
                            destination: ExamView2(),
                            label: {
                                Label("All Outcomes", systemImage: "graduationcap")
                            })
                    },
                    label: {
                        Label("Phase 3", systemImage: "graduationcap")
                    }
                )
            }
            .listStyle(SidebarListStyle())
            ExamView2()
            //            TopicView().colorScheme(.light)
        }.colorScheme(.light)
        //        #else
        //        Group {
        //            NavigationView {
        //                ExamView2()
        //            }
        //            .navigationViewStyle(StackNavigationViewStyle())
        //            .colorScheme(.light)
        //
        //            NavigationView {
        //                ExamView2()
        //            }
        //            .navigationViewStyle(StackNavigationViewStyle())
        //            .colorScheme(.dark)
        //        }
        //        #endif
    }
}

struct ListRow: View {
    var topic: Lesson
    var rating: Int
    
    var body: some View {
//        NavigationLink(destination: TopicView(topic: topic)) {
            HStack {
                Label(topic.title ?? "Untititled", systemImage: "heart")
                        .font(.headline)
                Spacer()
                    Text("Last studied: \(Date(), style: .date)")
                        .font(.footnote)
//                Spacer()
                ForEach(0..<rating) { _ in
                    Image(systemName: "star.fill")
                    //                                .renderingMode(.original)
                }
            }
//        }
        .foregroundColor(rating == 0 ? .primary : .black)
        .listRowBackground(backgroundColor(rating: rating))
    }
    
    func backgroundColor(rating: Int) -> Color? {
        switch rating {
        case 1: return Color(red: 0.922, green: 0.541, blue: 0.518, opacity: 1.000)
        case 2: return Color(red: 0.949, green: 0.799, blue: 0.545, opacity: 1.000)
        case 3: return Color(red: 0.690, green: 0.949, blue: 0.706, opacity: 1.000)
        default: return nil
        }
    }
}
