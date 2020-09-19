//
//  SummaryView.swift
//  Classes
//
//  Created by Nick Baughan on 13/09/2020.
//

import SwiftUI

struct SummaryView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
        animation: .default)
    private var lessons: FetchedResults<Lesson>
    
    @State var addLessonViewShown = false
    @State private var detailShown = false
    
    var todaysLessons: [Lesson] {
        let calendar = Calendar.current
        return lessons.filter({calendar.isDateInToday($0.date!)})
    }
    
    var overdueLessons: [Lesson] {
        return lessons.filter({$0.date! < Date() && !$0.watched})
    }
    
    func relativeDate(lesson: Lesson) -> Text {
        if lesson.date! < Date() {
            return Text("\(lesson.title ?? "No Title"): in \(lesson.date!, style: .relative)")
        } else {
            return Text("\(lesson.title ?? "No Title"):\(lesson.date!, style: .relative) ago")
        }
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.lesson?.date, ascending: true)],
        animation: .default)
    private var ilos: FetchedResults<ILO>
    
    var overdueILOs: [ILO] {
        return ilos.filter({$0.lesson!.date! < Date() && !$0.written})
    }
    
    var writtenILOs: Int {
        let ilos = self.ilos.filter({$0.written && $0.lesson!.date! < Date()})
        return ilos.count
    }
    
    var previousILOs: Int {
        let ilos = self.ilos.filter({$0.lesson!.date! < Date()})
        return ilos.count
    }
    
    var gridItem: [GridItem] = [GridItem(.adaptive(minimum: 300), spacing: 20, alignment: .top)]
    
    var body: some View {
            ScrollView {
                LazyVGrid(columns: gridItem, alignment: .leading, spacing: 20) {
                    TodaysLessonsView(detailShown: $detailShown, todaysLessons: todaysLessons)
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading) {
                                Label("Lessons to Watch", systemImage: "tv")
                                    .font(.headline)
                                Text("You have \(overdueLessons.count) Lessons to watch:")
                                    .font(.subheadline)
                                ForEach(overdueLessons) { lesson in
                                    let lesson = lesson as Lesson
                                    NavigationLink(
                                        destination: DetailView(lesson: lesson),
                                        label: {
                                            Label(lesson.title ?? "No Title", systemImage: Lesson.lessonIcon(type: lesson.type!))
                                        })
                                }
                            }
                            Spacer()
                        }
                    }
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading) {
                                Label("Notes to Write", systemImage: "doc.append")
                                    .font(.headline)
                                Text("You have written \(writtenILOs) learning outcomes out of \(previousILOs):")
                                    .font(.subheadline)
                                if ilos.count > 0 && previousILOs > 0 {
                                    ProgressView(value: Double(writtenILOs)/Double(previousILOs))
                                }
                                Text("You have \(overdueILOs.count) learning outcomes to write up:")
                                    .font(.subheadline)
                                ForEach(overdueILOs) { ilo in
                                    let ilo = ilo as ILO
                                    NavigationLink(
                                        destination: DetailView(lesson: ilo.lesson!),
                                        label: {
                                            Text(ilo.title ?? "No Title")
                                        })
                                }
                            }
                            Spacer()
                        }
                    }
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading) {
                                Label("Statistics", systemImage: "chart.pie")
                                    .font(.headline)
                                Text("Number of lessons: \(lessons.count)")
                                Text("Number of learning outcomes: \(ilos.count)")
                            }
                            Spacer()
                        }
                    }
                }
            }
            .sheet(isPresented: $addLessonViewShown) {
                AddLessonView(lesson: .constant(nil), isPresented: $addLessonViewShown)
                    .frame(minWidth: 200, idealWidth: 400, minHeight: 200, idealHeight: 250)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {addLessonViewShown = true}, label: {
                        Label("Add Lesson", systemImage: "plus")
                    })
                }
            }
            .padding(.horizontal)
            .navigationTitle("Summary")
        }
        //.navigationViewStyle(StackNavigationViewStyle())
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        #if !os(macOS)
        Group {
            SummaryView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            SummaryView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (2nd generation)"))
        }
        #else
        SummaryView()
        #endif
    }
}

struct TodaysLessonsView: View {
    @Binding var detailShown: Bool
    var todaysLessons: [Lesson]
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    Label("Today", systemImage: "calendar")
                        .font(.headline)
                    Text("You have \(todaysLessons.count) lessons today:")
                        .font(.subheadline)
                    ForEach(todaysLessons) { lesson in
                        let lesson = lesson as Lesson
                        #if !os(macOS)
                        VStack(alignment: .leading) {
                            Text("\(lesson.date ?? Date(), style: .time): ")
                                .font(.headline)
                                .underline()
                        }
                        NavigationLink(
                            destination: DetailView(lesson: lesson),
                            label: {
                                Label(
                                    title: {
                                        Text(lesson.title ?? "No Title")
                                    },
                                    icon: {
                                        Image(systemName: Lesson.lessonIcon(type: lesson.type!))
                                    })
                            })
                        #else
                        VStack(alignment: .leading) {
                            Text("\(lesson.date ?? Date(), style: .time): ")
                                .font(.headline)
                                .underline()
                            Label(
                                title: {
                                    Text(lesson.title ?? "No Title")
                                },
                                icon: {
                                    Image(systemName: Lesson.lessonIcon(type: lesson.type!))
                                })
                        }
                        #endif
                    }
                }
                Spacer()
            }
        }
    }
}
