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
    
    var todaysLessons: [Lesson] {
        let calendar = Calendar.current
        return lessons.filter({calendar.isDateInToday($0.date!)})
    }
    
    var overdueLessons: [Lesson] {
        return lessons.filter({$0.date! < Date()})
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
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading) {
                                Label("Today", systemImage: "calendar")
                                    .font(.headline)
                                Text("You have \(todaysLessons.count) classes today:")
                                    .font(.subheadline)
                                ForEach(todaysLessons) { lesson in
                                    let lesson = lesson as Lesson
                                    NavigationLink(
                                        destination: DetailView(lesson: lesson),
                                        label: {
                                            Text(lesson.title ?? "No Title")
                                        })
                                }
                            }
                            Spacer()
                        }
                    }
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
                                            Text(lesson.title ?? "No Title")
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
                            Text("You have written \(writtenILOs) ILOs out of \(ilos.count):")
                                .font(.subheadline)
                                ProgressView(value: ilos.count > 0 ? Double(writtenILOs)/Double(previousILOs) : 0)
                                Text("You have \(overdueILOs.count) ILOs to write up:")
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
                                Text("Number of ILOs: \(ilos.count)")
                            }
                            Spacer()
                        }
                    }
                }
            }
            .toolbar {
                EmptyView()
            }
            .padding()
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
